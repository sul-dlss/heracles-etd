import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['warning']

  static values = {
    maxFiles: Number,
    existingFiles: Number
  }

  validate (event) {
    const fileInput = event.target

    if ((fileInput.files.length + this.existingFilesValue) > this.maxFilesValue) {
      this.warningTarget.classList.remove('d-none')
      fileInput.setAttribute('aria-describedby', this.warningTarget.id)
      event.preventDefault()
      event.stopImmediatePropagation()
    } else {
      this.warningTarget.classList.add('d-none')
      fileInput.removeAttribute('aria-describedby')
    }
  }
}
