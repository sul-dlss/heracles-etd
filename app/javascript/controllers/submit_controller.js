import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  submit (event) {
    this.element.form.requestSubmit()
    // Disable form elements to wait for submission to complete.
    this.element.form.querySelectorAll('input, button, textarea, select').forEach(el => { el.disabled = true })
  }

  warn (event) {
    event.preventDefault()
    const element = new bootstrap.Modal(document.getElementById('files-still-attached-message')) // eslint-disable-line no-undef
    element.toggle()
  }
}
