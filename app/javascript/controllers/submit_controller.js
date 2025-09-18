import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  submit (event) {
    this.element.form.requestSubmit()
  }

  warn (event) {
    event.preventDefault()
    const element = new bootstrap.Modal(document.getElementById('files-still-attached-message')) // eslint-disable-line no-undef
    element.toggle()
  }
}
