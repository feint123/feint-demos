"use client"

import React, { useEffect, useMemo, useState } from "react";
import { Button, Link, Listbox, ListboxItem, Avatar, Modal, ModalContent, ModalHeader, ModalBody, Table, TableHeader, TableColumn, TableBody, Spinner, TableRow, TableCell, ModalFooter, useDisclosure, ScrollShadow, Chip, Select, SelectItem } from "@nextui-org/react";
import { AsyncListData, AsyncListLoadOptions, useAsyncList } from "@react-stately/data";
import { ToolsItem, ToolsSource } from "@/app/settings/page";
import { invoke } from "@tauri-apps/api/core";
import { AiOutlineExport, AiOutlineInfoCircle, AiOutlinePlus } from "react-icons/ai";
import { useRouter, useSearchParams } from "next/navigation";
import { SelectType } from "@/app/edittools/edit/page";
import { message, open } from "@tauri-apps/plugin-dialog";
import { Menu, MenuItem } from "@tauri-apps/api/menu";
import { ask } from "@tauri-apps/plugin-dialog";



export const EditSidenav = () => {

  const router = useRouter()
  async function createMenu(e: React.MouseEvent<HTMLElement, MouseEvent>, toolId: number) {
    e.preventDefault()

    let deleteItem = await MenuItem.new({
      text: "删除",
      accelerator: "CmdOrCtrl+Shift+D",
      action: () => {
        ask("是否删除该工具", { title: "删除", kind: "warning", okLabel: "确定", cancelLabel: "取消" })
          .then((ok) => {
            if (ok) {
              invoke("delete_source_item_by_id", { itemId: toolId })
                .then(async () => {
                  await message("删除成功", { title: "删除", kind: "info" });
                  router.push(`/edittools/edit`)
                })
                .catch(err => {
                  message(`删除工具失败【${err}】`, { title: "删除", kind: "error" });
                })
            }

          })
      }
    })
    let editItem = await MenuItem.new({
      text: "编辑",
      accelerator: "CmdOrCtrl+Shift+E",
      action: () => {
        console.log(toolId)
        router.replace(`/edittools/edit?toolId=${toolId}`)
      }
    })
    let menu = await Menu.new({
      items: [editItem, deleteItem]
    });
    menu.popup()
  }

  const [tools, setTools] = useState<ToolsItem[]>([])
  const [sources, setSources] = useState<ToolsSource[]>([])


  const [sourceNameMap,setSourceNameMap] = useState(new Map<string, string>())


  const { isOpen: isToolsOpen, onOpen: onToolsOpen, onOpenChange: onToolsOpenChange } = useDisclosure();
  function ToolsListModal() {
    const [selectedSource, setSelectedSource] = useState<SelectType>()

    const [isToolsLoading, setIsToolsLoading] = useState(true);
    let toolsList: AsyncListData<ToolsItem> = useAsyncList({
      async load(state: AsyncListLoadOptions<ToolsItem, string>) {

        if (isToolsOpen) {
          let result: ToolsItem[] = await invoke("get_source_item", { id: "" })
          setIsToolsLoading(false)
          return {
            items: result
          }
        } else {
          return {
            items: []
          }
        }
      }
    })

    function exportData() {

      open({
        directory: true,
        multiple: false,
        title: '选择导出目录',
        filters: [
        ],
      }).then(path => {
        if (path) {
          let selectId: number[] = []
          if (selectedSource == 'all') {
            selectId = toolsList.items.map(item => item.id ?? 0)
          } else {
            selectId = Array.from(selectedSource as Iterable<string>).map(item => Number.parseInt(item))
          }
          invoke("export_source", { toolsList: selectId, outPath: path })
            .then(async () => {
              await message(`导出成功, 文件路径【${path}/tools-export.json】`, { title: '工具源导出', kind: 'info' });
            })
            .catch(async err => {
              await message(`导出工具源失败【${err}】`, { title: '工具源导出', kind: 'error' });
            })
        }
      });

      // invoke("export_source", {toolsList:[], out_path:""})
    }


    return (
      <>
        <Modal isOpen={isToolsOpen} onOpenChange={onToolsOpenChange} size="2xl" backdrop="blur">
          <ModalContent>
            {(onClose) => (
              <>
                <ModalHeader className="flex flex-col gap-1">导出</ModalHeader>
                <ModalBody>
                  <ScrollShadow hideScrollBar orientation="vertical" className="h-[calc(100vh-280px)]">
                    <Table shadow="none" isHeaderSticky isStriped aria-label="tools source table" selectionMode="multiple"
                      selectedKeys={selectedSource}
                      onSelectionChange={setSelectedSource} className="text-left"
                    >
                      <TableHeader>
                        <TableColumn allowsSorting>标题</TableColumn>
                        <TableColumn>简介</TableColumn>
                      </TableHeader>
                      <TableBody emptyContent={"你还有添加任何工具哟"} items={toolsList.items}
                        isLoading={isToolsLoading}
                        loadingContent={<Spinner label="Loading..." />}>
                        {
                          (item: ToolsItem) => {
                            return (<TableRow key={item.id}>
                              <TableCell>
                                <div className="flex flex-row gap-2">
                                  <span>{item.title}</span>
                                  <Chip startContent={<AiOutlineInfoCircle />} color="primary" variant="flat" className="text-[0.5rem] h-4 mt-[2px]" size="sm">{sourceNameMap.get(item.tools_source_id??"")}</Chip>
                                </div>
                              </TableCell>
                              <TableCell>
                                <div className="flex flex-col">
                                  <p className="truncate">{item.description}</p>
                                  <p className="text-xs text-foreground-500">{item.target_url}</p>
                                </div></TableCell>
                            </TableRow>)
                          }
                        }

                      </TableBody>
                    </Table>
                  </ScrollShadow>
                </ModalBody>
                <ModalFooter>
                  <Button startContent={<AiOutlineExport />} color="default" size="sm" variant="flat" onClick={exportData}>导出</Button>
                </ModalFooter>
              </>
            )}
          </ModalContent>
        </Modal>
      </>
    )
  }
  const topContent = useMemo(() => {
    return (
      <div className="flex flex-row gap-2 justify-start p-2 border-b border-default-200">
        <Button startContent={<AiOutlinePlus />} color="default" size="sm" variant="flat" as={Link} href="/edittools/edit">新建</Button>
        <Button startContent={<AiOutlineExport />} color="default" size="sm" variant="flat" onClick={onToolsOpen}>导出</Button>
      </div>
    )
  }, [onToolsOpen])

  const params = useSearchParams();
  const toolId = params.get("toolId")
  const [selectedToolId, setSelectedToolId] = useState<SelectType>()
  useEffect(() => {
    if (toolId) {
      setSelectedToolId([toolId])
    }
    invoke("get_source_item", { id: "" }).then(items=>{
      if (items instanceof Array) {
        setTools(items)
      }
    })

    invoke("get_all_source", {}).then(items=>{
      if (items instanceof Array) {
        setSources(items)
        setSourceNameMap(new Map(items.map(item=>[item.source_id, item.name])))
      }
    })
  }, [setSelectedToolId, toolId, useAsyncList, setTools, setSources, setSourceNameMap])

  return (
    <div>
      <ToolsListModal />
      <Listbox topContent={topContent} label="工具列表" emptyContent="没有工具哦" className="rounded-tr-lg bg-default-100 shadow h-[calc(100vh-64px)] px-0 py-2"
        selectedKeys={selectedToolId} onSelectionChange={setSelectedToolId} disallowEmptySelection selectionMode="single" items={tools}
        classNames={{
          list: "max-h-[calc(100vh-64px)] overflow-y-auto overflow-x-hidden px-2",
        }}>
        {
          (item: ToolsItem) => {
            return (
              <ListboxItem className="pl-0" onContextMenu={(e) => { createMenu(e, item.id ?? 0) }} textValue={item.title} key={item.id ?? "0"} href={`/edittools?toolId=${item.id}`} >
                <div className="flex gap-2 items-center pl-2">
                  <Avatar isBordered alt={item.title} className="flex-shrink-0" size="sm" src={item.cover_image_url} />

                  <div className="flex flex-col text-left w-full truncate gap-1">
                    <div className="flex flex-row gap-2">
                      <span className="text-small truncate">{item.title}</span>
                      <Chip startContent={<AiOutlineInfoCircle/>} color="primary" variant="flat" className="text-[0.5rem] h-4 mt-[2px]" size="sm">{sourceNameMap.get(item.tools_source_id??"")}</Chip>
                    </div>

                    <span className="text-tiny text-default-400 truncate">{item.description}</span>
                  </div>
                </div>
              </ListboxItem>
            )
          }
        }
      </Listbox>
    </div>


  );
}