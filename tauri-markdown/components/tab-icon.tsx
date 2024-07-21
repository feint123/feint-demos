import { AiOutlineAudio, AiOutlineCode, AiOutlineFileImage, AiOutlineFileWord, AiOutlineInbox, AiOutlineRobot, AiOutlineTool, AiOutlineVideoCamera } from "react-icons/ai"

export function TabIcon({ category }: { category: string }) {

    switch (category) {
        case "音频":
            return <AiOutlineAudio />
        case "视频":
            return <AiOutlineVideoCamera />
        case "文档":
            return <AiOutlineFileWord />
        case "编程":
            return <AiOutlineCode />
        case "AI":
            return <AiOutlineRobot />
        case "聚合":
            return <AiOutlineInbox />
        case "图片":
            return <AiOutlineFileImage />
        default:
            return <AiOutlineTool />
    }

}