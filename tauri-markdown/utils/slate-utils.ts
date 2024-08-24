import { CustomEditor, LinkElement } from "@/types"
import {
    Editor,
    Element as SlateElement,
    Range,
    Transforms,
  } from 'slate'

 export const isLinkActive = (editor: CustomEditor) => {
    const link = Editor.nodes(editor, {
      match: n =>
        !Editor.isEditor(n) && SlateElement.isElement(n) && n.type === 'link',
    })
    return !!link
  }
  
export const unwrapLink = (editor: CustomEditor) => {
    Transforms.unwrapNodes(editor, {
      match: n =>
        !Editor.isEditor(n) && SlateElement.isElement(n) && n.type === 'link',
    })
  }
export const wrapLink = (editor: CustomEditor, url: string) => {
    if (isLinkActive(editor)) {
      unwrapLink(editor)
    }
  
    const { selection } = editor
    const isCollapsed = selection && Range.isCollapsed(selection)
    const link: LinkElement = {
      type: 'link',
      url,
      children: isCollapsed ? [{ text: url }] : [],
    }
  
    if (isCollapsed) {
      Transforms.insertNodes(editor, link)
    } else {
      Transforms.wrapNodes(editor, link, { split: true })
      Transforms.collapse(editor, { edge: 'end' })
    }
  }

  export const toggleMark = (editor: Editor, format: string) => {
    const isActive = isMarkActive(editor, format)

    if (isActive) {
        Editor.removeMark(editor, format)
    } else {
        Editor.addMark(editor, format, true)
    }
}

type FormatType = 'bold' | 'italic' | 'underline' | 'code'
export const isMarkActive = (editor: Editor, format: string) => {
    const marks = Editor.marks(editor)
    // Check if `marks` is not null and is of type `Partial<Pick<CustomText, 'bold' | 'italic' | 'code' | 'highlight'>>`
    if (marks) {
        // Narrow down the type of `marks` to the expected properties
        const validFormats: Set<string> = new Set(['bold', 'italic', 'code', 'highlight']);
        if (validFormats.has(format)) {
            // Use type assertion to ensure TypeScript understands that `marks` will have the key `format`
            return (marks as Record<string, boolean>)[format] === true;
        }
    }

}