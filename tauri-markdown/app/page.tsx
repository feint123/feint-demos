"use client"
import { ClipboardEventHandler, useCallback, useEffect, useMemo, useState } from "react";
import {
  createEditor,
  Editor,
  Element as SlateElement,
  Point,
  Range,
  Transforms,
  Descendant,
  BaseSelection,
  Text as SlateText,
} from 'slate'
import { withHistory } from 'slate-history'
import { Editable, RenderElementProps, RenderLeafProps, Slate, useSlateStatic, withReact } from 'slate-react'
import { BlockQuoteElement, BulletedListElement, CustomEditor, CustomElement, DividerElement, ImageElement, LinkElement, ParagraphElement, SortedListElement, TaskListElement } from "@/types";
import "github-markdown-css"
import { Button, Code, Divider, DropdownItem, Link, Popover, PopoverContent, PopoverTrigger, ScrollShadow } from "@nextui-org/react";
import { HoveringToolbar } from "@/components/hovering-toolbar";
import { open } from "@tauri-apps/plugin-shell";
import './style.css'
import { VscAdd, VscFileMedia } from "react-icons/vsc";
import { CheckListItemElement } from "@/components/check-list-item";
import { Menu, MenuItem, PredefinedMenuItem } from "@tauri-apps/api/menu";
import { toggleMark, wrapLink } from "@/utils/slate-utils";


const SHORTCUTS: Map<String, ShortcutsType> = new Map(Object.entries({
  '*': 'list-item',
  '--': 'divider',
  '- [ ]': 'task-list-item',
  '—': 'divider',
  '>': 'block-quote-item',
  '#': 'heading-one',
  '##': 'heading-two',
  '###': 'heading-three',
  '####': 'heading-four',
  '#####': 'heading-five',
  '######': 'heading-six',
}))
type ShortcutsType = "bulleted-list" | "sorted-list" | "task-list" | "paragraph" | "block-quote" | "block-quote-item" | "list-item" | "sorted-list-item"
  | "task-list-item" | "code-line" | "divider" | "image" | "link" | "heading-one" | "heading-two" | "heading-three" | "heading-four" | "heading-five" | "heading-six"
  | undefined
export default function Home() {
  const renderElement = useCallback((props: RenderElementProps) => <Element {...props} />, [])
  const renderLeaf = useCallback((props: RenderLeafProps) => <Leaf {...props} />, [])
  const [showPanel, setShowPanel] = useState(false)
  const [showLink, setShowLink] = useState(false)
  const [panelTop, setPanelTop] = useState(-999)
  const [panelLeft, setPanelLeft] = useState(-999)
  const [editor] = useState(
    () => withInline(withShortcuts(withReact(withHistory(createEditor())))),
  )

  const onEditorChange = useCallback((value: Descendant[]) => {
    const isAstChange = editor.operations.some(
      op => 'set_selection' !== op.type
    )
    if (isAstChange) {
      // Save the value to Local Storage.
      const content = JSON.stringify(value)
      localStorage.setItem('content', content)
    }
  }, [])

  let initialValue:Descendant[] = [ {
    type: 'paragraph',
    children: [{ text: '' }],
  }]
  

  useEffect(
    () => {
      let history = JSON.parse(localStorage.getItem('content')??"[]")??[];

      editor.children = history;
      return ()=>{}
    },
    [editor]
  )
  const floatToolBar = useMemo(() => {
    return (
      <div className="absolute flex flex-col gap-1 shadow-md rounded-md py-1 px-2 top-[64px] right-4 z-50">
        <Popover placement="left">
          <PopoverTrigger>
            <Button variant="light" size="sm" isIconOnly>
              <VscAdd />
            </Button>
          </PopoverTrigger>
          <PopoverContent>
            <DropdownItem
              key="new"
              shortcut="⌘N"
              startContent={<VscFileMedia />}
            >
              图片
            </DropdownItem>
          </PopoverContent>
        </Popover>

        <Button variant="light" size="sm" isIconOnly>
          格式
        </Button>
      </div>
    )
  }, [])

  const selectionChange = useCallback((selection: BaseSelection) => {

    if (!selection || Editor.string(editor, selection) === '' || Range.isCollapsed(selection)) {
      setShowPanel(false)
      setShowLink(false)
      return
    }

    setShowPanel(true)

    const domSelection = window.getSelection()
    if ((domSelection?.rangeCount ?? 0 > 0)) {
      const domRange = domSelection?.getRangeAt(0)
      let rect = {
        top: 0,
        left: 0,
        width: 0,
        height: 0,
      }
      if (domRange?.getClientRects && domRange.getClientRects().length > 0) {
        let clientReact = domRange.getClientRects()[domRange.getClientRects().length - 1]
        rect = clientReact
      }
      setPanelTop(rect.top + window.scrollY - 45)
      setPanelLeft(Math.min(window.innerWidth - 200 - 8, Math.max(8, rect.left + window.scrollX - 200 / 2 + rect.width / 2)))
    }
  }, [])

  const onEditorPaste = useCallback<ClipboardEventHandler<HTMLDivElement>>((event) => {
    const items = event.clipboardData?.items;
    if (items) {
      for (let i = 0; i < items.length; i++) {
        // 寻找图片类型的项
        if (items[i].type.indexOf('image') !== -1) {
          const blob = items[i].getAsFile();
          // 将Blob对象转换为Base64编码
          convertImageToBase64(blob!)
            .then(base64String => {
              Editor.insertText(editor, ' ')
              const newProperties: Partial<SlateElement> = {
                type: "image",
                url: base64String as string ?? "",
              }
              Transforms.setNodes<SlateElement>(editor, newProperties, {
                match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n),
              })
              Editor.insertBreak(editor)
              insertParagraph(editor)

            })
            .catch(error => {
              console.error('Error converting image to Base64:', error);
            });
          break;
        } else if (items[i].type.match("^text/plain")) {
          items[i].getAsString(clipboardData => {
            if (clipboardData?.startsWith("http://") || clipboardData?.startsWith("https://")) {
              event.preventDefault()
              wrapLink(editor, clipboardData)
            }
          });
        }
      }
    }
  }, [])

  function appendShortcut(shortcut: (editor: CustomEditor) => void) {
    const { selection } = editor
    if (selection) {
      const match = Editor.above(editor, {
        match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n),
      })
      if (match) {
        const [block, path] = match
        const start = Editor.start(editor, path)
        shortcut(editor)
        if (Point.equals(selection?.anchor, start)) {
          Editor.insertFragment(editor, block.children)
        }
        return
      }
    }
    shortcut(editor)
  }
  async function createMenu(e: React.MouseEvent<HTMLElement, MouseEvent>) {
    e.preventDefault()
    setShowPanel(false)
    let todoItem = await MenuItem.new({
      text: "添加代办事项",
      accelerator: "CmdOrCtrl+Shift+T",
      action: () => {
        appendShortcut((editor) => {
          Editor.insertText(editor, '- [ ]')
          Editor.insertText(editor, ' ')
        })
      }
    })

    let listItem = await MenuItem.new({
      text: "添加列表",
      accelerator: "CmdOrCtrl+Shift+U",
      action: () => {
        appendShortcut((editor) => {
          Editor.insertText(editor, '*')
          Editor.insertText(editor, ' ')
        })
      }
    })


    let quotaItem = await MenuItem.new({
      text: "添加引用",
      accelerator: "CmdOrCtrl+Shift+Q",
      action: () => {
        appendShortcut((editor) => {
          Editor.insertText(editor, '>')
          Editor.insertText(editor, ' ')
        })
      }
    })

    let dividerItem = await MenuItem.new({
      text: "添加分割线",
      accelerator: "CmdOrCtrl+Shift+D",
      action: () => {

        Editor.insertText(editor, '--')
        Editor.insertText(editor, ' ')
      }
    })
    let copyItem = await PredefinedMenuItem.new({
      text: "拷贝",
      item: "Copy"
    })

    let cutItem = await PredefinedMenuItem.new({
      text: "剪切",
      item: "Cut"
    })

    let pasteItem = await PredefinedMenuItem.new({
      text: "黏贴",
      item: "Paste"
    })
    let menu = await Menu.new({
      items: [todoItem, listItem, quotaItem, dividerItem, copyItem, cutItem, pasteItem]
    });
    menu.popup()
  }

  return (
    <ScrollShadow orientation="vertical" hideScrollBar className="h-[calc(100vh-70px)] editor w-full p-8 bg-background rounded-lg items-center flex justify-center">
      {/* {floatToolBar} */}
      <Slate editor={editor} initialValue={initialValue} onChange={onEditorChange}
        onSelectionChange={selectionChange}>
        <HoveringToolbar showPanel={showPanel} top={panelTop} left={panelLeft} showLink={showLink}
          onLinkClick={() => { setShowLink(true) }} onSubmitLink={(link: string) => {
            Editor.removeMark(editor, "highlight")
            setShowPanel(false)
            setShowLink(false)
          }} />
        <Editable className="markdown-body h-full w-full max-w-screen-xl focus:outline-none focus-visible:outline-none caret-blue-500"
          renderElement={renderElement}
          renderLeaf={renderLeaf}
          placeholder="请输入"
          spellCheck
          autoFocus
          onContextMenu={createMenu}
          onFocus={() => {
            Editor.removeMark(editor, "highlight")
          }}
          onPaste={onEditorPaste}
          onKeyDown={(event) => {
            if (event.key === 'Tab' && event.shiftKey) {
              event.preventDefault()
              const { selection } = editor
              if (selection && Range.isCollapsed(selection)) {
                const match = Editor.above(editor, {
                  match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n) && ["list-item", "sorted-list-item", "task-list-item"].includes(n.type),
                })
                if (match) {
                  const [block, path] = match
                  const [parent, ppath] = Editor.parent(editor, path)

                  if (parent && SlateElement.isElement(parent) && Editor.isBlock(editor, parent)) {
                      Transforms.moveNodes(editor, {at:path, to: ppath})
                      const next = Editor.next(editor, {at:ppath})
                      const nextPath = next?.[1]
                      const nextNode = next?.[0]
                      if(nextNode && SlateElement.isElement(nextNode) && Editor.isBlock(editor, nextNode) && nextNode.children.length == 1
                       && SlateText.isText(nextNode.children[0]) && nextNode.children[0].text == '') {
                        Transforms.removeNodes(editor, {at:nextPath})
                      } else if(nextPath) {
                        Transforms.moveNodes(editor, {at:ppath, to: nextPath })
                      }
                  }
                  return
                }
              }
            } else if (event.key === 'Tab') {
              event.preventDefault()
              Editor.insertText(editor, "\t")
            }
          }}
          onDOMBeforeInput={(event: InputEvent) => {
            switch (event.inputType) {
              case 'formatBold':
                event.preventDefault()
                return toggleMark(editor, 'bold')
              case 'formatItalic':
                event.preventDefault()
                return toggleMark(editor, 'italic')
              case 'formatUnderline':
                event.preventDefault()
                return toggleMark(editor, 'underlined')
            }
          }}
        />
      </Slate>
    </ScrollShadow>
  );
}

async function convertImageToBase64(blob: File) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

function unwrap(block: CustomElement, parent: CustomElement, editor: CustomEditor) {
  const newProperties: Partial<SlateElement> = {
    type: 'paragraph',
  }
  Transforms.setNodes(editor, newProperties)
  if (block.type === 'list-item' || parent.type === 'bulleted-list') {
    Transforms.unwrapNodes(editor, {
      match: n =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'bulleted-list',
      split: true,
    })
  } else if (block.type === 'block-quote-item' || parent.type === 'block-quote') {
    Transforms.unwrapNodes(editor, {
      match: n =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'block-quote',
      split: true,
    })
  } else if (block.type === 'sorted-list-item' || parent.type === 'sorted-list') {
    Transforms.unwrapNodes(editor, {
      match: n =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'sorted-list',
      split: true,
    })
  } else if (block.type === 'task-list-item') {
    Transforms.unwrapNodes(editor, {
      match: n =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'task-list',
      split: true,
    })
  }
}
function wrap(type: any, editor: CustomEditor) {
  if (type === 'list-item') {
    const list: BulletedListElement = {
      type: 'bulleted-list',
      children: [],
    }
    Transforms.wrapNodes(editor, list, {
      match: (n) =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'list-item',
    })
  } else if (type === 'block-quote-item') {
    const block: BlockQuoteElement = {
      type: 'block-quote',
      children: []
    }
    Transforms.wrapNodes(editor, block, {
      match: (n) =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'block-quote-item',
    })
  } else if (type == 'sorted-list-item') {
    const list: SortedListElement = {
      type: 'sorted-list',
      children: [],
    }
    Transforms.wrapNodes(editor, list, {
      match: (n) =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'sorted-list-item',
    })
  } else if (type == 'task-list-item') {
    const list: TaskListElement = {
      type: 'task-list',
      children: [],
    }
    Transforms.wrapNodes(editor, list, {
      match: (n) =>
        !Editor.isEditor(n) &&
        SlateElement.isElement(n) &&
        n.type === 'task-list-item',
    })
  } else if (type == 'divider') {
    insertParagraph(editor)
  }
}
const insertDivider = (editor: CustomEditor) => {
  const text = { text: '' }
  const voidNode: DividerElement = {
    type: 'divider',
    children: [text],
  }
  Transforms.insertNodes(editor, voidNode)
}
const insertParagraph = (editor: CustomEditor) => {
  const text = { text: '' }
  const newProperties: ParagraphElement = {
    type: 'paragraph',
    children: [text]
  }
  Transforms.insertNodes(editor, newProperties)
}

const insertImage = (editor: CustomEditor, url: string) => {
  const text = { text: '' }
  const newProperties: ImageElement = {
    type: 'image',
    children: [text],
    url
  }
  Transforms.insertNodes(editor, newProperties)
}



const withInline = (editor: CustomEditor) => {
  const { deleteBackward, insertText, insertBreak, isVoid, isInline } = editor

  editor.isInline = element => (element.type === 'link' ? true : isInline(element))
  editor.insertText = text => {
    const { selection } = editor
    insertText(text)
  }
  return editor
}
const withShortcuts = (editor: CustomEditor) => {
  const { deleteBackward, insertText, insertBreak, isVoid } = editor
  editor.insertBreak = () => {
    const { selection } = editor

    if (selection) {
      const match = Editor.above(editor, {
        match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n),
      })

      if (match) {
        const [block, path] = match
        const start = Editor.start(editor, path)
        if (
          !Editor.isEditor(block) &&
          SlateElement.isElement(block)
        ) {
          if (block.type.includes('heading') && !Point.equals(selection.anchor, start)) {
            insertBreak()
            const newProperties: Partial<SlateElement> = {
              type: 'paragraph',
            }
            Transforms.setNodes(editor, newProperties)
            return
          } else if (Point.equals(selection.anchor, start)) {
            const [parent, ppath] = Editor.parent(editor, path)
            if (!Editor.isEditor(parent) &&
              SlateElement.isElement(parent))
              unwrap(block, parent, editor)
            if (block.type === 'paragraph' || block.type.includes('heading')) {
              insertBreak()
            }
            return
          }
        }
      }
    }
    insertBreak()
  }
  editor.isVoid = element => (['divider', 'image'].includes(element.type) ? true : isVoid(element))
  editor.insertText = text => {
    const { selection } = editor
    if (text.endsWith('\t') && selection && Range.isCollapsed(selection)) {
      const { anchor } = selection
      const block = Editor.above(editor, {
        match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n) && ['list-item', 'sorted-list-item'].includes(n.type),
      })
      if (block) {
        const ele = block[0]
        if (!Editor.isEditor(ele) && Editor.isBlock(editor, ele)) {
          const range = { anchor, focus: { path: anchor.path, offset: anchor.offset - 1 } }
          Transforms.select(editor, range)
          const newProperties: Partial<SlateElement> = {
            type: ele.type,
          }
          Transforms.setNodes<SlateElement>(editor, newProperties, {
            match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n),
          })
          wrap(ele.type, editor)
        }
      }
    }

    if (text.endsWith(' ') && selection && Range.isCollapsed(selection)) {
      const { anchor } = selection
      const block = Editor.above(editor, {
        match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n),
      })
      const path = block ? block[1] : []
      const start = Editor.start(editor, path)
      const range = { anchor, focus: start }
      const beforeText = Editor.string(editor, range) + text.slice(0, -1)
      let type = SHORTCUTS.get(beforeText)
      if (!type && beforeText.match(/\d\./)) {
        type = "sorted-list-item"
      }

      if (type) {
        Transforms.select(editor, range)

        if (!Range.isCollapsed(range)) {
          Transforms.delete(editor)
        }
        const newProperties: Partial<SlateElement> = {
          type,
          checked: false,
        }
        Transforms.setNodes<SlateElement>(editor, newProperties, {
          match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n),
        })

        wrap(type, editor)
        return
      }
    }

    insertText(text)
  }

  editor.deleteBackward = (...args) => {
    const { selection } = editor

    if (selection && Range.isCollapsed(selection)) {
      const match = Editor.above(editor, {
        match: n => SlateElement.isElement(n) && Editor.isBlock(editor, n),
      })

      if (match) {
        const [block, path] = match
        const start = Editor.start(editor, path)

        if (
          !Editor.isEditor(block) &&
          SlateElement.isElement(block) &&
          Point.equals(selection.anchor, start)
        ) {
          const [parent, ppath] = Editor.parent(editor, path)
          if (!Editor.isEditor(parent) && SlateElement.isElement(parent))
            unwrap(block, parent, editor)
          if (block.type === 'paragraph' || block.type.includes('heading')) {
            deleteBackward(...args)
          }
          return
        }
      }

      deleteBackward(...args)
    }
  }

  return editor
}
const Leaf = ({ attributes, children, leaf }: { attributes: any, children: any, leaf: any }) => {
  if (leaf.bold) {
    children = <strong>{children}</strong>
  }

  if (leaf.italic) {
    children = <em>{children}</em>
  }

  if (leaf.underlined) {
    children = <u>{children}</u>
  }

  if (leaf.code) {
    children = <Code>{children}</Code>
  }

  if (leaf.highlight) {
    children = <span className="inline-block bg-sky-500 animate-pulse " style={{ backgroundColor: '#3b82f655' }}>{children}</span>
  }

  return <span {...attributes}>{children}</span>
}



const Element = ({ attributes, children, element }: { attributes: any, children: any, element: any }) => {
  const editor = useSlateStatic()
  const props = { attributes, children, element }
  switch (element.type) {
    case 'block-quote':
      return <blockquote {...attributes}>{children}</blockquote>
    case 'block-quote-inline':
      return <p {...attributes}> {children}</p>
    case 'bulleted-list':
      return <ul {...attributes}>{children}</ul>
    case 'sorted-list':
      return <ol {...attributes}>{children}</ol>
    case 'task-list':
      return <div className="flex flex-col mb-4" {...attributes}>{children}</div>
    case 'task-list-item':
      // console.log(attributes, element)
      return <CheckListItemElement {...props} />
    case 'heading-one':
      return <h1 {...attributes}>{children}</h1>
    case 'heading-two':
      return <h2 {...attributes}>{children}</h2>
    case 'heading-three':
      return <h3 {...attributes}>{children}</h3>
    case 'heading-four':
      return <h4 {...attributes}>{children}</h4>
    case 'heading-five':
      return <h5 {...attributes}>{children}</h5>
    case 'heading-six':
      return <h6 {...attributes}>{children}</h6>
    case 'list-item':
    case 'sorted-list-item':
      return <li {...attributes}>{children}</li>
    case 'divider':
      return <div {...attributes}><Divider />{children}</div>
    case 'link':
      return <Link className="cursor-pointer" href={element.url} {...attributes} onClick={() => { open(element.url) }}>{children}</Link>
    case 'image':
      return (
        <div className="w-full flex justify-center p-2">
          <img
            {...attributes}
            src={element.url}
            alt="image"
            className="object-cover"
          />
          {children}
        </div>
      )
    default:
      return <p {...attributes}>{children}</p>
  }
}

