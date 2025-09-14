import { createCliRenderer, type CliRenderer } from "../index"
import { ListRenderable, type ListItem } from "../renderables/List"
import { BoxRenderable } from "../renderables/Box"
import { TextRenderable } from "../renderables/Text"
import { RGBA } from "../lib/RGBA"
import { getKeyHandler } from "../lib/KeyHandler"

interface TodoItem {
  id: number
  text: string
  completed: boolean
  priority: "low" | "medium" | "high"
}

const todoItems: ListItem<TodoItem>[] = [
  {
    label: "📝 Write documentation",
    value: { id: 1, text: "Write documentation", completed: false, priority: "high" },
  },
  {
    label: "🐛 Fix bug in renderer",
    value: { id: 2, text: "Fix bug in renderer", completed: false, priority: "high" },
  },
  { label: "✨ Add new feature", value: { id: 3, text: "Add new feature", completed: false, priority: "medium" } },
  { label: "🧪 Write tests", value: { id: 4, text: "Write tests", completed: true, priority: "medium" } },
  { label: "🎨 Improve UI design", value: { id: 5, text: "Improve UI design", completed: false, priority: "low" } },
  { label: "♻️ Refactor old code", value: { id: 6, text: "Refactor old code", completed: false, priority: "low" } },
  {
    label: "📚 Update dependencies",
    value: { id: 7, text: "Update dependencies", completed: true, priority: "medium" },
  },
  {
    label: "🚀 Deploy to production",
    value: { id: 8, text: "Deploy to production", completed: false, priority: "high" },
    disabled: true,
  },
]

const fruitItems: ListItem<string>[] = [
  { label: "🍎 Apple", value: "apple" },
  { label: "🍌 Banana", value: "banana" },
  { label: "🍊 Orange", value: "orange" },
  { label: "🍇 Grapes", value: "grapes" },
  { label: "🍓 Strawberry", value: "strawberry" },
  { label: "🥝 Kiwi", value: "kiwi" },
  { label: "🍑 Peach", value: "peach" },
  { label: "🍒 Cherry", value: "cherry" },
]

async function run() {
  const renderer = await createCliRenderer()
  const root = renderer.root

  // Title
  const title = new TextRenderable(renderer, {
    id: "title",
    content: "📋 List Component Demo",
    position: "absolute",
    left: 2,
    top: 1,
    fg: RGBA.fromValues(1, 1, 0.5, 1),
    attributes: 1, // Bold
  })
  root.add(title)

  // Todo List (vertical)
  const todoListContainer = new BoxRenderable(renderer, {
    id: "todo-container",
    position: "absolute",
    left: 2,
    top: 3,
    width: 40,
    height: 12,
    border: true,
    borderStyle: "double",
    title: "Todo List",
    titleAlignment: "center",
    backgroundColor: RGBA.fromValues(0.05, 0.05, 0.1, 1),
    borderColor: RGBA.fromValues(0.3, 0.5, 0.8, 1),
  })
  root.add(todoListContainer)

  const todoList = new ListRenderable<TodoItem>(renderer, {
    id: "todo-list",
    items: todoItems,
    selectedIndex: 0,
    maxVisible: 8,
    showBorder: false,
    position: "absolute",
    left: 1,
    top: 1,
    width: 38,
    height: 10,
    renderItem: (item, _index, selected) => {
      const checkbox = item.value.completed ? "✅" : "☐"
      const prefix = selected ? "▶" : " "
      return `${prefix} ${checkbox} ${item.label}`
    },
    onSelect: (item) => {
      item.value.completed = !item.value.completed
      todoList.setItems([...todoItems]) // Refresh the list
      updateStatus(`Toggled: ${item.value.text}`)
    },
    onChange: (item) => {
      updateStatus(`Selected: ${item.value.text}`)
    },
    selectedBg: RGBA.fromValues(0.2, 0.3, 0.6, 1),
    selectedFg: RGBA.fromValues(1, 1, 1, 1),
    normalFg: RGBA.fromValues(0.7, 0.7, 0.8, 1),
    disabledFg: RGBA.fromValues(0.3, 0.3, 0.4, 1),
  })
  todoListContainer.add(todoList)

  // Fruit List (horizontal)
  const fruitListContainer = new BoxRenderable(renderer, {
    id: "fruit-container",
    position: "absolute",
    left: 45,
    top: 3,
    width: 50,
    height: 5,
    border: true,
    borderStyle: "single",
    title: "Fruit Selection (Horizontal)",
    titleAlignment: "center",
    backgroundColor: RGBA.fromValues(0.05, 0.1, 0.05, 1),
    borderColor: RGBA.fromValues(0.3, 0.8, 0.3, 1),
  })
  root.add(fruitListContainer)

  const fruitList = new ListRenderable<string>(renderer, {
    id: "fruit-list",
    items: fruitItems,
    orientation: "horizontal",
    selectedIndex: 0,
    showBorder: false,
    position: "absolute",
    left: 1,
    top: 1,
    width: 48,
    height: 3,
    renderItem: (item, _index, selected) => {
      return selected ? `[${item.label}]` : item.label
    },
    onSelect: (item) => {
      updateStatus(`You selected: ${item.value}`)
    },
    selectedBg: RGBA.fromValues(0.2, 0.5, 0.2, 1),
    selectedFg: RGBA.fromValues(1, 1, 0.5, 1),
    normalFg: RGBA.fromValues(0.6, 0.8, 0.6, 1),
  })
  fruitListContainer.add(fruitList)

  // Simple list without border
  const simpleList = new ListRenderable<number>(renderer, {
    id: "simple-list",
    position: "absolute",
    left: 45,
    top: 10,
    width: 25,
    height: 10,
    items: Array.from({ length: 20 }, (_, i) => ({
      label: `Item ${i + 1}`,
      value: i + 1,
      disabled: i === 5 || i === 10,
    })),
    maxVisible: 8,
    showBorder: true,
    indicator: "→",
    selectedBg: RGBA.fromValues(0.5, 0.2, 0.5, 1),
    onSelect: (item) => {
      updateStatus(`Selected item with value: ${item.value}`)
    },
  })
  root.add(simpleList)

  // Status text
  let statusText = new TextRenderable(renderer, {
    id: "status",
    content: "Use arrow keys to navigate, Enter/Space to select",
    position: "absolute",
    left: 2,
    top: renderer.height - 3,
    fg: RGBA.fromValues(0.8, 0.8, 0.8, 1),
  })
  root.add(statusText)

  // Helper function to update status
  const updateStatus = (text: string) => {
    root.remove(statusText.id)
    statusText = new TextRenderable(renderer, {
      id: "status",
      content: text,
      position: "absolute",
      left: 2,
      top: renderer.height - 3,
      fg: RGBA.fromValues(0.8, 0.8, 0.8, 1),
    })
    root.add(statusText)
  }

  // Instructions
  const instructions = new BoxRenderable(renderer, {
    id: "instructions",
    position: "absolute",
    left: 2,
    top: 16,
    width: 40,
    height: 6,
    border: true,
    borderStyle: "single",
    title: "Controls",
    padding: 1,
    backgroundColor: RGBA.fromValues(0.05, 0.05, 0.05, 1),
  })
  root.add(instructions)

  const instructionText = new TextRenderable(renderer, {
    id: "instruction-text",
    content: `↑/↓ or j/k - Navigate vertically
←/→ or h/l - Navigate horizontally
Enter/Space - Select item
Home/End - Jump to first/last
Tab - Switch focus between lists`,
    position: "absolute",
    left: 1,
    top: 1,
    fg: RGBA.fromValues(0.6, 0.6, 0.7, 1),
  })
  instructions.add(instructionText)

  // Focus management
  let focusedList = 0
  const lists = [todoList, fruitList, simpleList]
  lists[focusedList].focus()

  // Handle tab key to switch focus
  const keyHandler = getKeyHandler()
  keyHandler.on("tab", () => {
    lists[focusedList].blur()
    focusedList = (focusedList + 1) % lists.length
    lists[focusedList].focus()
    updateStatus(`Focused: ${lists[focusedList].id}`)
    return true
  })

  // Exit on ctrl+c
  keyHandler.on("ctrl+c", () => {
    renderer.stop()
    process.exit(0)
  })

  renderer.start()

  return renderer
}

export default run
