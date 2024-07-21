"use client"
import { ToolsItem } from "@/app/settings/page"
import { Avatar, Button, Divider, Link } from "@nextui-org/react"
import { AsyncListData, AsyncListLoadOptions, useAsyncList } from "@react-stately/data"
import { invoke } from "@tauri-apps/api/core"
import { useEffect, useMemo, useState } from "react"
import { Navigation, Pagination } from "swiper/modules"
import { Swiper, SwiperSlide } from "swiper/react"
import 'swiper/css';
import 'swiper/css/navigation';
import { open } from "@tauri-apps/plugin-shell"
import { AiOutlineEdit } from "react-icons/ai"
import { Image } from "antd"
import { motion } from "framer-motion"
import Markdown from "react-markdown"
import "github-markdown-css"
import remarkGfm from "remark-gfm"

export default function ToolsDetail({ toolsId }: { toolsId: string }) {

  const tools: AsyncListData<ToolsItem> = useAsyncList({
    async load(state: AsyncListLoadOptions<ToolsItem, string>) {
      let result: ToolsItem[] = []
      try {
        result = await invoke("get_source_item_by_id", { itemId: Number.parseInt(toolsId) })
      } catch (err) {
        console.log(err)
      }
      return {
        items: result
      }

    },
  })



  const swiperSlides = useMemo(() => tools.items[0]?.preview_image_url?.map((image, index) => (
    <SwiperSlide key={index} className="item-center justify-center align-center">
      <Image
        preview={{
          maskClassName: "rounded-lg",
          classNames: { mask: "backdrop-blur-md" },
        }}
        className="w-full h-full rounded-lg"
        alt="工具预览"
        src={image}
      />
    </SwiperSlide>

  )), [tools])


  const categorySections = []


  function openOnBroswer(target_url: string | undefined) {
    if (target_url) {
      open(target_url);
    }
  }


  useEffect(()=>{
    document.querySelectorAll(".markdown-body a").forEach((link)=>{
      link.addEventListener("click", (e) => {
        e.preventDefault()
        openOnBroswer(link.getAttribute("href")??"")
      })
    })
  },[openOnBroswer])

  return (
    tools.items[0] ? (
      <motion.div layout initial={{ y: -10, opacity: 0.2 }} animate={{ y: 0, opacity: 1 }}
        transition={{ type: 'spring', stiffness: 100 }}
        className="w-full pb-8">
        <div className="flex flex-row mb-8 gap-4 justify-between text-left">
          <Avatar size="lg" isBordered radius="lg" className="min-w-[64px] h-[64px]" src={tools.items[0]?.cover_image_url} />

          <div className="flex flex-col w-full">
            <div className="flex flex-row gap-1">
              <h2 className="text-2xl font-semibold line-clamp-1">{tools.items[0]?.title}</h2>
              <Link href={`/edittools/edit?toolId=${tools.items[0]?.id}`} size="sm"><AiOutlineEdit className="text-lg text-foreground-500" /></Link>
            </div>
            <p className="font-light text-base text-gray-500 line-clamp-1 max-w-lg">{tools.items[0]?.description}</p>
          </div>
          <Button color="primary" className="my-auto" size="sm" variant="flat" radius="full" onClick={() => { openOnBroswer(tools.items[0]?.target_url) }}>获取</Button>

        </div>
        <Divider />
        {tools.items[0]?.preview_image_url ? (
          <div>
            <h2 className="text-xl font-semibold mt-8 mb-4 text-left">预览</h2>
            <Swiper slidesPerView={3}
              // centeredSlides={true}
              spaceBetween={10}
              navigation={true}
              modules={[Pagination, Navigation]}
              className="mb-8">

              {swiperSlides}
            </Swiper>
          </div>
        ) : (
          <></>
        )
        }

        <h2 className="text-xl font-semibold mt-8 mb-4 text-left">说明</h2>
        <Markdown remarkPlugins={[remarkGfm]} className="markdown-body select-text mb-8 py-2 px-3 rounded-lg text-left text-wrap break-words">
          {tools.items[0]?.content}
        </Markdown>

      </motion.div>
    ) : (
      <div></div>
    )
  );
}
