import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["current"]
  static values = { url: String }

  async increment() {
    const current = parseInt(this.currentTarget.textContent) || 0
    await this.updateProgress(current + 1)
  }

  async decrement() {
    const current = parseInt(this.currentTarget.textContent) || 0
    if (current > 0) {
      await this.updateProgress(current - 1)
    }
  }

  async updateProgress(value) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": token
        },
        body: JSON.stringify({ current_value: value })
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Failed to update progress:", error)
    }
  }
}
