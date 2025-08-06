import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "notReadyAlert", "readyAlert"]

  connect() {
    this.completedSteps = new Set()
    this._updateSubmitButton()
  }

  stepDone(step) {
    this.completedSteps.add(step)
    this._updateSubmitButton()
  }

  stepUndone(step) {
    this.completedSteps.delete(step)
    this._updateSubmitButton()
  }

  _updateSubmitButton() {
    if (this.completedSteps.size === 6) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("disabled")
      this.notReadyAlertTarget.classList.add("d-none")
      this.readyAlertTarget.classList.remove("d-none")
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("disabled")
      this.notReadyAlertTarget.classList.remove("d-none")
      this.readyAlertTarget.classList.add("d-none")
    }
  }
}