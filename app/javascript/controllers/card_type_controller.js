import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields"]
  static values = { current: String }

  connect() {
    this.showFieldsForType(this.currentValue)
  }

  change(event) {
    const selectedType = event.target.value
    this.showFieldsForType(selectedType)
  }

  showFieldsForType(type) {
    this.fieldsTargets.forEach(field => {
      if (field.dataset.type === type) {
        field.classList.remove("hidden")
      } else {
        field.classList.add("hidden")
      }
    })
  }
}
