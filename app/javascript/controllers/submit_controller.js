import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  submit () {
    this.element.form.requestSubmit()
  }

  warn (event) {
    event.preventDefault()
    const element = new bootstrap.Modal(document.getElementById('permission-files-message')) // eslint-disable-line no-undef
    element.toggle()
  }
}
