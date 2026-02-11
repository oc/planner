import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column", "card"]
  static values = { productSlug: String }

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    this.cardTargets.forEach(card => {
      card.addEventListener("dragstart", this.handleDragStart.bind(this))
      card.addEventListener("dragend", this.handleDragEnd.bind(this))
    })

    this.columnTargets.forEach(column => {
      column.addEventListener("dragover", this.handleDragOver.bind(this))
      column.addEventListener("dragleave", this.handleDragLeave.bind(this))
      column.addEventListener("drop", this.handleDrop.bind(this))
    })
  }

  handleDragStart(event) {
    this.draggedCard = event.target.closest("[data-card-id]")
    this.draggedCard.classList.add("opacity-50")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedCard.dataset.cardId)
  }

  handleDragEnd(event) {
    if (this.draggedCard) {
      this.draggedCard.classList.remove("opacity-50")
    }
    this.columnTargets.forEach(column => {
      column.classList.remove("bg-blue-50")
    })
  }

  handleDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("bg-blue-50")
  }

  handleDragLeave(event) {
    event.currentTarget.classList.remove("bg-blue-50")
  }

  handleDrop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("bg-blue-50")

    const cardId = event.dataTransfer.getData("text/plain")
    const newStage = column.dataset.stage
    const cards = Array.from(column.querySelectorAll("[data-card-id]"))
    const position = this.calculatePosition(event, cards)

    // Move card in DOM
    if (position === cards.length) {
      column.appendChild(this.draggedCard)
    } else {
      column.insertBefore(this.draggedCard, cards[position])
    }

    // Update server
    this.updateCardPosition(cardId, newStage, position + 1)
  }

  calculatePosition(event, cards) {
    const y = event.clientY
    for (let i = 0; i < cards.length; i++) {
      const rect = cards[i].getBoundingClientRect()
      if (y < rect.top + rect.height / 2) {
        return i
      }
    }
    return cards.length
  }

  async updateCardPosition(cardId, stage, position) {
    const url = `/products/${this.productSlugValue}/cards/${cardId}/move`
    const csrfToken = document.querySelector("[name='csrf-token']").content

    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ stage, position })
      })

      if (!response.ok) {
        console.error("Failed to move card")
        window.location.reload()
      }
    } catch (error) {
      console.error("Error moving card:", error)
      window.location.reload()
    }
  }
}
