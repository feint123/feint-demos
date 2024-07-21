"use client"
import {
  Navbar as NextUINavbar,
  NavbarContent,
  NavbarBrand,
  NavbarItem} from "@nextui-org/navbar";
import { Button } from "@nextui-org/button";

import { SlMagnifier } from "react-icons/sl";
import { Tab, Tabs, Tooltip } from "@nextui-org/react";
import { usePathname, useRouter } from "next/navigation";
import { invoke } from "@tauri-apps/api/core";
import { AiOutlineAppstore, AiOutlineCloud, AiOutlineEdit, AiOutlineEye, AiOutlineInfoCircle, AiOutlineTool } from "react-icons/ai";
import { useEffect } from "react";
import { useTheme } from "next-themes";
import { emit, listen, TauriEvent } from "@tauri-apps/api/event";
import { getCurrent } from "@tauri-apps/api/webviewWindow";
import { VscChevronLeft, VscRefresh, VscSave, VscSettings } from "react-icons/vsc";



export const Navbar = () => {
  const { theme, setTheme } = useTheme();
  useEffect(() => {
    setInterval(()=> {
      document.querySelector("nav header")?.setAttribute("data-tauri-drag-region", "true")
    },1000)
    getCurrent().theme().then(theme => {
      setTheme(theme as string)
    }).catch(e => {
      console.log(e)
    })
    listen(TauriEvent.WINDOW_THEME_CHANGED, (event) => {
      if (typeof event.payload === "string") {
        setTheme(event.payload)
      }
    });
  }, [setTheme])

  const router = useRouter();
  let pathname = usePathname();
  const sourcePathname = pathname;

  const backPageList = ["/details"]
  function goBack() {
    router.back();
  }

  function openSettingsWindow() {
    invoke("show_settings").catch(e => {
      console.log(e)
    })
  }
  function SettingButton() {
    if (pathname != "/settings") {
      return (
        <Tooltip content="设置" size="sm">
        <Button onClick={openSettingsWindow} variant="light" size="sm" isIconOnly startContent={<VscSettings className="text-lg text-default-600"/>}>
        </Button>
        </Tooltip>
      )
    } else {
      return <></>
    }
  }

  function SaveButton() {
    if (sourcePathname.includes("/edittools/edit")) {
      return (
        <Tooltip content="保存信息" size="sm">
        <Button onClick={() => { emit("SAVE_TOOLS_INFO") }} variant="light" size="sm" isIconOnly 
        startContent={<VscSave className="text-lg text-default-600"/>}>
        </Button>
        </Tooltip>
        )
    } else {
      return  <></>
    }
  }
  function NavTitle() {
    if (pathname == "/settings") {
      return (
        <span className="font-bold">设置</span>
      )
    } else {
      return <></>
    }
  }

  function NavWarpper({ children }: { children: React.ReactNode }) {
    return <NextUINavbar shouldHideOnScroll={false} height={"52px"} className="bg-default-100" data-tauri-drag-region maxWidth="full">{children}</NextUINavbar>
  }
  function OptionNav() {
    if (pathname.includes("/settings")) {
      return (<NavWarpper>
        <NavbarBrand></NavbarBrand>
        <NavbarContent data-tauri-drag-region className="gap-4" justify="center">
          <Tabs selectedKey={pathname} size="sm" radius="full">
            <Tab key="/settings" title={
              <div className="flex items-center space-x-2">
                <AiOutlineTool />
                <span>工具源</span>
              </div>
            } href="/settings"></Tab>
            <Tab isDisabled key="/settings/appearence" title={
              <div className="flex items-center space-x-2">
                <AiOutlineEye />
                <span>外观</span>
              </div>
            } href="/settings/appearence"></Tab>
            <Tab key="/settings/about" title={
              <div className="flex items-center space-x-2">
                <AiOutlineInfoCircle />
                <span>关于</span>
              </div>
            } href="/settings/about"></Tab>
          </Tabs>
        </NavbarContent>
        <NavbarContent data-tauri-drag-region justify="end">
          <NavbarItem>
          </NavbarItem>
        </NavbarContent>
      </NavWarpper>)
    }
    if (backPageList.includes(pathname)) {
      return (<NavWarpper>
        <NavbarBrand data-tauri-drag-region>
          <Button className="ml-16" onClick={goBack} variant="light" size="sm" isIconOnly startContent={<VscChevronLeft className="text-lg text-default-600" />}></Button>
        </NavbarBrand>
        <NavbarContent data-tauri-drag-region className="gap-4" justify="center">
          <NavTitle />
        </NavbarContent>
        <NavbarContent data-tauri-drag-region justify="end">
          <NavbarItem>
            <SettingButton />
          </NavbarItem>
        </NavbarContent>
      </NavWarpper>
      )
    } else {
      return (<NavWarpper>
        <NavbarBrand data-tauri-drag-region></NavbarBrand>
        <NavbarContent data-tauri-drag-region className="gap-4" justify="center">
          <Tabs size="sm" radius="full" aria-label="Options" selectedKey={pathname}>
          </Tabs>
        </NavbarContent>
        <NavbarContent data-tauri-drag-region justify="end" className="gap-2">
          <NavbarItem>
            <SaveButton/>
          </NavbarItem>
          <NavbarItem>
            <Tooltip content="刷新页面" size="sm">
            <Button onClick={() => { location.reload() }} variant="light" size="sm" isIconOnly startContent={<VscRefresh className="text-lg text-default-600"/>}>
            </Button>
            </Tooltip>
          </NavbarItem>
          <NavbarItem>
            <SettingButton />
          </NavbarItem>
        </NavbarContent>
      </NavWarpper>)

    }
  }
  return (
    <OptionNav />
  );
};
