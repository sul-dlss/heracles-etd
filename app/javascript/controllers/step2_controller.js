import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['doneButton']

  toggleButton (event) {
    if (event.target.value.trim().length > 0) {
      this.doneButtonTarget.disabled = false
    } else {
      this.doneButtonTarget.disabled = true
    }
  }
}
