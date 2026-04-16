import { Controller } from "@hotwired/stimulus"

// Composer: Enter submits, Shift+Enter newline. Clears the input and resets
// height immediately on submit so the UI feels instant — the new bubble is
// painted by a Turbo Stream broadcast moments later.
export default class extends Controller {
  static targets = ["input"]

  maybeSubmit(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }

  autoresize() {
    const el = this.inputTarget
    el.style.height = "auto"
    el.style.height = Math.min(el.scrollHeight, 200) + "px"
  }

  clearOnSubmit() {
    requestAnimationFrame(() => {
      this.inputTarget.value = ""
      this.inputTarget.style.height = "auto"
      this.inputTarget.focus()
    })
  }
}
