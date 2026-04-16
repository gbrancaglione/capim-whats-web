import { Controller } from "@hotwired/stimulus"

const CATEGORIES = {
  "Smileys & People": [
    "😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃","😉","😊","😇","🥰","😍","🤩",
    "😘","😗","😚","😙","😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔","🤐","🤨",
    "😐","😑","😶","😏","😒","🙄","😬","🤥","😌","😔","😪","🤤","😴","😷","🤒","🤕",
    "🤢","🤮","🥵","🥶","🥴","😵","🤯","🤠","🥳","😎","🤓","🧐","😕","😟","🙁","☹️",
    "😮","😯","😲","😳","🥺","😦","😧","😨","😰","😥","😢","😭","😱","😖","😣","😞",
    "😓","😩","😫","🥱","😤","😡","😠","🤬","😈","👿","💀","☠️","💩","🤡","👹","👺"
  ],
  "Gestures & Body": [
    "👋","🤚","🖐","✋","🖖","👌","🤌","🤏","✌️","🤞","🤟","🤘","🤙","👈","👉","👆",
    "🖕","👇","☝️","👍","👎","✊","👊","🤛","🤜","👏","🙌","👐","🤲","🤝","🙏","💪",
    "🦾","🦿","🦵","🦶","👂","🦻","👃","🧠","👀","👁","👅","👄","💋"
  ],
  "Hearts & Symbols": [
    "❤️","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❣️","💕","💞","💓","💗","💖",
    "💘","💝","💟","✨","⭐","🌟","💫","💥","🔥","🌈","☀️","🌙","⚡","☁️","❄️","💧"
  ],
  "Animals & Nature": [
    "🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🙈",
    "🙉","🙊","🐔","🐧","🐦","🐤","🦆","🦅","🦉","🐺","🐗","🐴","🦄","🐝","🐛","🦋",
    "🌸","🌼","🌻","🌹","🌷","🌱","🌳","🌴","🍀","🍁","🍂"
  ],
  "Food & Drink": [
    "🍎","🍊","🍋","🍌","🍉","🍇","🍓","🍈","🍒","🍑","🥭","🍍","🥥","🥝","🍅","🍆",
    "🥑","🥦","🥒","🌶","🌽","🥕","🍞","🧀","🥩","🥓","🍔","🍟","🍕","🌭","🥪","🌮",
    "🌯","🥗","🍝","🍜","🍣","🍤","🍦","🍩","🍪","🎂","🍰","🍫","🍿","🍷","🍺","☕"
  ],
  "Activities & Objects": [
    "⚽","🏀","🏈","⚾","🎾","🏐","🏉","🎱","🏓","🏸","🥊","🥋","🎯","🎮","🎲","🎸",
    "🎹","🎺","🎻","🥁","🎬","🎤","🎧","📱","💻","⌨️","🖥","🖨","📷","📸","📹","🎥",
    "💡","🔦","🕯","💰","💎","🔑","🔒","🎁","🎈","🎉","🎊","🏆","🥇","🥈","🥉"
  ]
}

// Lightweight emoji picker — curated grid, no third-party dep. Inserts the
// chosen glyph at the current caret position of the composer textarea.
export default class extends Controller {
  static targets = ["panel", "input"]

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    if (this.panelTarget.children.length === 0) this.render()
    this.panelTarget.classList.toggle("hidden")
  }

  hideOnOutside(event) {
    if (this.element.contains(event.target)) return
    this.panelTarget.classList.add("hidden")
  }

  render() {
    const frag = document.createDocumentFragment()
    for (const [name, list] of Object.entries(CATEGORIES)) {
      const section = document.createElement("section")
      section.className = "mt-3 first:mt-0"

      const heading = document.createElement("h4")
      heading.className = "mb-1.5 text-[11px] font-semibold uppercase tracking-[0.04em] text-neutral-medium"
      heading.textContent = name
      section.appendChild(heading)

      const grid = document.createElement("div")
      grid.className = "grid grid-cols-8 gap-0.5"
      for (const e of list) {
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "cursor-pointer rounded-md border-0 bg-transparent p-1.5 text-[22px] leading-none transition hover:bg-neutral-background"
        btn.textContent = e
        btn.addEventListener("click", () => this.insert(e))
        grid.appendChild(btn)
      }
      section.appendChild(grid)
      frag.appendChild(section)
    }
    this.panelTarget.appendChild(frag)
  }

  insert(glyph) {
    const input = this.inputTarget
    const start = input.selectionStart ?? input.value.length
    const end   = input.selectionEnd ?? input.value.length
    input.value = input.value.slice(0, start) + glyph + input.value.slice(end)
    const caret = start + glyph.length
    input.focus()
    input.setSelectionRange(caret, caret)
    input.dispatchEvent(new Event("input", { bubbles: true }))
  }
}
