import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['doneButton']

  connect () {
    this.toggleButton({ target: { value: '' } })
  }

  toggleButton (event) {
    if (event.target.value.trim().length > 0) {
      this.doneButtonTarget.disabled = false
      this.doneButtonTarget.classList.remove('disabled')
    } else {
      this.doneButtonTarget.disabled = true
      this.doneButtonTarget.classList.add('disabled')
    }
  }
}
