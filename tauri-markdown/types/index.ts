import { SVGProps } from "react";
import { BaseEditor, BaseRange, Descendant } from "slate";
import { HistoryEditor } from "slate-history";
import { ReactEditor } from "slate-react";

export type IconSvgProps = SVGProps<SVGSVGElement> & {
  size?: number;
};

export type BlockQuoteElement = {
  type: 'block-quote'
  align?: string
  children: Descendant[]
}

export type BulletedListElement = {
  type: 'bulleted-list'
  align?: string
  children: Descendant[]
}

export type SortedListElement = {
  type: 'sorted-list'
  align?: string
  children: Descendant[]
}

export type TaskListElement = {
  type: 'task-list'
  children: Descendant[]
}

export type DividerElement = {
  type: 'divider'
  children: Descendant[]
}

export type ImageElement = {
  type: 'image'
  url: string
  children: Descendant[]
}

export type LinkElement = {
  type: 'link'
  url: string
  children: Descendant[]
}

export type ListItemElement = { type: 'list-item'; children: Descendant[] }
export type SortedListItemElement = { type: 'sorted-list-item'; children: Descendant[] }
export type BlockQuoteItemElement = { type: 'block-quote-item'; children: Descendant[] }

export type HeadingOneElement = { type: 'heading-one'; children: Descendant[] }
export type HeadingTwoElement = { type: 'heading-two'; children: Descendant[] }
export type HeadingThreeElement = { type: 'heading-three'; children: Descendant[] }
export type HeadingFourElement = { type: 'heading-four'; children: Descendant[] }
export type HeadingFiveElement = { type: 'heading-five'; children: Descendant[] }
export type HeadingSixElement = { type: 'heading-six'; children: Descendant[] }

export type CodeLineElement = {
  type: 'code-line'
  children: Descendant[]
}

export type TaskListItemElement = { type: 'task-list-item'; checked: boolean; children: Descendant[] }

export type ParagraphElement = {
  type: 'paragraph'
  align?: string
  children: Descendant[]
}



export type CustomText = {
  bold?: boolean
  italic?: boolean
  code?: boolean
  highlight?: boolean
  text: string
}

export type EmptyText = {
  text: string
}

export type CustomElement =
  | BulletedListElement
  | SortedListElement
  | TaskListElement
  | ParagraphElement
  | BlockQuoteElement
  | BlockQuoteItemElement
  | ListItemElement
  | SortedListItemElement
  | TaskListItemElement
  | CodeLineElement
  | DividerElement
  | ImageElement
  | LinkElement
  | HeadingOneElement
  | HeadingTwoElement
  | HeadingThreeElement
  | HeadingFourElement
  | HeadingFiveElement
  | HeadingSixElement
 
export type CustomEditor = BaseEditor &
  ReactEditor &
  HistoryEditor & {
    nodeToDecorations?: Map<Element, Range[]>
  }

declare module 'slate' {
  interface CustomTypes {
    Editor: CustomEditor
    Element: CustomElement
    Text: CustomText | EmptyText
    Range: BaseRange & {
      [key: string]: unknown
    }
  }
}