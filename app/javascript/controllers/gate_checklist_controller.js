import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    cardId: Number,
    productSlug: String,
    stage: String
  }

  async toggle(event) {
    const checkbox = event.target
    const gate = checkbox.dataset.gate
    const checked = checkbox.checked

    const url = `/products/${this.productSlugValue}/cards/${this.cardIdValue}/toggle_gate`
    const csrfToken = document.querySelector("[name='csrf-token']").content

    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: JSON.stringify({
          stage: this.stageValue,
          gate: gate,
          checked: checked.toString()
        })
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      } else {
        checkbox.checked = !checked
        console.error("Failed to toggle gate")
      }
    } catch (error) {
      checkbox.checked = !checked
      console.error("Error toggling gate:", error)
    }
  }
}
