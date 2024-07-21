"use client"
import { useState } from "react"
import { useSlate } from "slate-react"
import { Editor } from "slate"
import { Button, Input, Popover, PopoverContent, PopoverTrigger, Tooltip } from "@nextui-org/react"
import { VscCheck } from "react-icons/vsc"
import { GoBold, GoCode, GoItalic, GoLink } from "react-icons/go";
import { AiOutlineUnderline } from "react-icons/ai"
import { wrapLink } from "@/app/page"
import { RiRobot2Line } from "react-icons/ri";


export const HoveringToolbar = ({ showPanel, top, left, showLink, onLinkClick, onSubmitLink }:
    { showPanel: boolean, top: number, left: number, showLink: boolean, onLinkClick?: () => void, onSubmitLink?: (link: string) => void }) => {
    const [linkVal, setLinkVal] = useState("")
    const editor = useSlate()

    const FormatButton = ({ format, icon, type }: { format: string, icon: React.ReactNode, type?: string }) => {

        return (
            <div
                className={isMarkActive(editor, format) ? "bg-primary dark:bg-primary/50 text-primary-foreground rounded-md"
                    : ""}
                onClick={(e) => {
                    if (type == "link") {
                        if (onLinkClick) {
                            onLinkClick()
                        }
                    } else {
                        toggleMark(editor, format)
                    }
                }}
            >
                <div className="hover:bg-primary-100/50 px-2 py-1 rounded-md">
                    {icon}
                </div>
            </div>
        )
    }

    return (
        (<div className="bg-default-100 shadow-lg rounded-md border-small
            border-default-200  z-50  absolute flex p-1" style={{ top: top, left: left, display: showPanel ? "flex" : "none" }}>
            {showLink ? (
                <div className="flex flex-row gap-1">
                    <Input isClearable value={linkVal} onValueChange={setLinkVal} size="sm"
                        className="min-w-[300px]" color="primary"
                        placeholder="请输入链接，例如：www.bilibili.com" onFocus={e => {
                            Editor.addMark(editor, 'highlight', true)
                        }} />
                    <Button isIconOnly size="sm" color="primary" variant="faded" onClick={e => {
                        e.preventDefault()
                        if (onSubmitLink) {
                            onSubmitLink(linkVal)
                        }
                        wrapLink(editor, linkVal)
                        setLinkVal("")
                    }}><VscCheck className="text-lg" /></Button>
                </div>

            ) : (<div className="flex flex-row gap-1 " onMouseDown={e => {
                // prevent toolbar from taking focus away from editor
                e.preventDefault()
            }}><FormatButton format="bold" icon={<GoBold className="text-lg" />} />
                <FormatButton format="italic" icon={<GoItalic className="text-lg" />} />
                <FormatButton format="link" type="link" icon={<GoLink className="text-lg" />} />
                <FormatButton format="underlined" icon={<AiOutlineUnderline className="text-lg" />} />
                <FormatButton format="code" icon={<GoCode className="text-lg" />} />
            </div>
            )}
        </div>)
    )

}

export const toggleMark = (editor: Editor, format: string) => {
    const isActive = isMarkActive(editor, format)

    if (isActive) {
        Editor.removeMark(editor, format)
    } else {
        Editor.addMark(editor, format, true)
    }
}
interface Marks {
    [key: string]: boolean;
}
const isMarkActive = (editor: Editor, format: string) => {
    const marks = Editor.marks(editor)
    return marks ? marks[format] === true : false
}



