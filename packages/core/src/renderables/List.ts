import { Renderable, type RenderableOptions } from "../Renderable"
import { TextRenderable } from "./Text"
import { BoxRenderable } from "./Box"
import { RGBA, parseColor } from "../lib/RGBA"
import type { RenderContext } from "../types"
import type { OptimizedBuffer } from "../buffer"

export interface ListItem<T = any> {
  label: string
  value: T
  disabled?: boolean
}

export interface ListOptions<T = any> extends RenderableOptions<ListRenderable<T>> {
  items: ListItem<T>[]
  selectedIndex?: number
  onSelect?: (item: ListItem<T>, index: number) => void
  onChange?: (item: ListItem<T>, index: number) => void
  orientation?: "vertical" | "horizontal"
  renderItem?: (item: ListItem<T>, index: number, selected: boolean) => string
  selectedBg?: string | RGBA
  selectedFg?: string | RGBA
  normalFg?: string | RGBA
  disabledFg?: string | RGBA
  focusable?: boolean
  scrollable?: boolean
  maxVisible?: number
  showBorder?: boolean
  indicator?: string
}

export class ListRenderable<T = any> extends Renderable {
  private items: ListItem<T>[]
  private selectedIndex: number
  private scrollOffset: number = 0
  private onSelect?: (item: ListItem<T>, index: number) => void
  private onChange?: (item: ListItem<T>, index: number) => void
  private orientation: "vertical" | "horizontal"
  private renderItem?: (item: ListItem<T>, index: number, selected: boolean) => string
  private selectedBg: RGBA
  private selectedFg: RGBA
  private normalFg: RGBA
  private disabledFg: RGBA
  private scrollable: boolean
  private maxVisible?: number
  private showBorder: boolean
  private indicator: string
  private container: BoxRenderable | null = null
  private itemRenderables: TextRenderable[] = []

  protected _defaultOptions = {
    items: [],
    selectedIndex: 0,
    orientation: "vertical" as const,
    selectedBg: RGBA.fromValues(0, 0.4, 0.8, 1),
    selectedFg: RGBA.fromValues(1, 1, 1, 1),
    normalFg: RGBA.fromValues(0.8, 0.8, 0.8, 1),
    disabledFg: RGBA.fromValues(0.4, 0.4, 0.4, 1),
    focusable: true,
    scrollable: true,
    showBorder: true,
    indicator: "▶",
  } satisfies Partial<ListOptions<T>>

  constructor(ctx: RenderContext, options: ListOptions<T>) {
    super(ctx, options)

    this.items = options.items || []
    this.selectedIndex = options.selectedIndex ?? 0
    this.onSelect = options.onSelect
    this.onChange = options.onChange
    this.orientation = options.orientation || "vertical"
    this.renderItem = options.renderItem
    this.scrollable = options.scrollable ?? true
    this.maxVisible = options.maxVisible
    this.showBorder = options.showBorder ?? true
    this.indicator = options.indicator ?? "▶"
    this.focusable = options.focusable ?? true

    // Parse colors
    this.selectedBg =
      typeof options.selectedBg === "string"
        ? parseColor(options.selectedBg)
        : options.selectedBg || this._defaultOptions.selectedBg
    this.selectedFg =
      typeof options.selectedFg === "string"
        ? parseColor(options.selectedFg)
        : options.selectedFg || this._defaultOptions.selectedFg
    this.normalFg =
      typeof options.normalFg === "string"
        ? parseColor(options.normalFg)
        : options.normalFg || this._defaultOptions.normalFg
    this.disabledFg =
      typeof options.disabledFg === "string"
        ? parseColor(options.disabledFg)
        : options.disabledFg || this._defaultOptions.disabledFg

    // Create container if using border
    if (this.showBorder) {
      this.container = new BoxRenderable(ctx, {
        id: `${this.id}-container`,
        border: true,
        borderStyle: "single",
        padding: 1,
        width: "100%",
        height: "100%",
      })
      this.add(this.container)
    }

    // Initialize items
    this.updateItemRenderables()
  }

  private updateItemRenderables() {
    // Clear existing items
    const parent = this.container || this
    this.itemRenderables.forEach((item) => parent.remove(item.id))
    this.itemRenderables = []

    // Calculate visible range
    const startIdx = this.scrollable && this.maxVisible ? this.scrollOffset : 0
    const endIdx = this.maxVisible ? Math.min(startIdx + this.maxVisible, this.items.length) : this.items.length

    // Create renderables for visible items
    for (let i = startIdx; i < endIdx; i++) {
      const item = this.items[i]
      const isSelected = i === this.selectedIndex
      const relativeIndex = i - startIdx

      const text = this.renderItem
        ? this.renderItem(item, i, isSelected)
        : `${isSelected ? this.indicator + " " : "  "}${item.label}`

      const fg = item.disabled ? this.disabledFg : isSelected ? this.selectedFg : this.normalFg
      const bg = isSelected && !item.disabled ? this.selectedBg : RGBA.fromValues(0, 0, 0, 0)

      const textRenderable = new TextRenderable(this.ctx, {
        id: `${this.id}-item-${i}`,
        content: text,
        fg,
        bg,
        position: "absolute",
        width: this.orientation === "vertical" ? "100%" : undefined,
        height: this.orientation === "vertical" ? 1 : "100%",
        left: this.orientation === "horizontal" ? relativeIndex * 20 : 0, // Default 20 chars per item
        top: this.orientation === "vertical" ? relativeIndex : 0,
      })

      this.itemRenderables.push(textRenderable)
      parent.add(textRenderable)
    }

    this.requestRender()
  }

  public selectNext() {
    const prevIndex = this.selectedIndex
    let nextIndex = this.selectedIndex

    do {
      nextIndex = (nextIndex + 1) % this.items.length
    } while (this.items[nextIndex]?.disabled && nextIndex !== prevIndex)

    if (nextIndex !== prevIndex) {
      this.selectedIndex = nextIndex
      this.ensureVisible(nextIndex)
      this.updateItemRenderables()
      this.onChange?.(this.items[nextIndex], nextIndex)
    }
  }

  public selectPrevious() {
    const prevIndex = this.selectedIndex
    let nextIndex = this.selectedIndex

    do {
      nextIndex = nextIndex === 0 ? this.items.length - 1 : nextIndex - 1
    } while (this.items[nextIndex]?.disabled && nextIndex !== prevIndex)

    if (nextIndex !== prevIndex) {
      this.selectedIndex = nextIndex
      this.ensureVisible(nextIndex)
      this.updateItemRenderables()
      this.onChange?.(this.items[nextIndex], nextIndex)
    }
  }

  public selectFirst() {
    for (let i = 0; i < this.items.length; i++) {
      if (!this.items[i].disabled) {
        this.selectedIndex = i
        this.ensureVisible(i)
        this.updateItemRenderables()
        this.onChange?.(this.items[i], i)
        break
      }
    }
  }

  public selectLast() {
    for (let i = this.items.length - 1; i >= 0; i--) {
      if (!this.items[i].disabled) {
        this.selectedIndex = i
        this.ensureVisible(i)
        this.updateItemRenderables()
        this.onChange?.(this.items[i], i)
        break
      }
    }
  }

  private ensureVisible(index: number) {
    if (!this.scrollable || !this.maxVisible) return

    if (index < this.scrollOffset) {
      this.scrollOffset = index
    } else if (index >= this.scrollOffset + this.maxVisible) {
      this.scrollOffset = index - this.maxVisible + 1
    }
  }

  public handleSelect() {
    const item = this.items[this.selectedIndex]
    if (item && !item.disabled) {
      this.onSelect?.(item, this.selectedIndex)
    }
  }

  public setItems(items: ListItem<T>[]) {
    this.items = items
    this.selectedIndex = Math.min(this.selectedIndex, items.length - 1)
    this.scrollOffset = 0
    this.updateItemRenderables()
  }

  public getSelectedItem(): ListItem<T> | undefined {
    return this.items[this.selectedIndex]
  }

  public getSelectedIndex(): number {
    return this.selectedIndex
  }

  public setSelectedIndex(index: number) {
    if (index >= 0 && index < this.items.length && !this.items[index].disabled) {
      this.selectedIndex = index
      this.ensureVisible(index)
      this.updateItemRenderables()
    }
  }

  handleKeyPress(key: string): boolean {
    if (!this.focused) return false

    // Handle navigation keys
    if (this.orientation === "vertical") {
      if (key === "down" || key === "j") {
        this.selectNext()
        return true
      } else if (key === "up" || key === "k") {
        this.selectPrevious()
        return true
      }
    } else {
      if (key === "right" || key === "l") {
        this.selectNext()
        return true
      } else if (key === "left" || key === "h") {
        this.selectPrevious()
        return true
      }
    }

    // Common keys
    if (key === "enter" || key === "space") {
      this.handleSelect()
      return true
    } else if (key === "home") {
      this.selectFirst()
      return true
    } else if (key === "end") {
      this.selectLast()
      return true
    }

    return false
  }

  protected renderSelf(buffer: OptimizedBuffer, deltaTime: number) {
    // Draw scroll indicators if needed
    if (this.scrollable && this.maxVisible && this.items.length > this.maxVisible) {
      const hasMoreAbove = this.scrollOffset > 0
      const hasMoreBelow = this.scrollOffset + this.maxVisible < this.items.length

      if (hasMoreAbove) {
        buffer.drawText("▲", this.x + this.width - 2, this.y, this.normalFg, RGBA.fromValues(0, 0, 0, 0))
      }

      if (hasMoreBelow) {
        buffer.drawText(
          "▼",
          this.x + this.width - 2,
          this.y + this.height - 1,
          this.normalFg,
          RGBA.fromValues(0, 0, 0, 0),
        )
      }
    }
  }
}
