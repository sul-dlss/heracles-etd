import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['body']

  collapseAndSubmit (event) {
    event.preventDefault()
    const form = event.target.form

    const handler = function (event) {
      if (event.target !== this.bodyTarget) return
      form.requestSubmit()
      event.target.removeEventListener('hidden.bs.collapse', handler)
    }.bind(this)

    this.bodyTarget.addEventListener('hidden.bs.collapse', handler)
    bootstrap.Collapse.getOrCreateInstance(this.bodyTarget).hide() // eslint-disable-line no-undef
  }

  expandAndSubmit (event) {
    event.preventDefault()
    const form = event.target.form

    const handler = function (event) {
      if (event.target !== this.bodyTarget) return
      form.requestSubmit()
      event.target.removeEventListener('shown.bs.collapse', handler)
    }.bind(this)

    this.bodyTarget.addEventListener('shown.bs.collapse', handler)
    bootstrap.Collapse.getOrCreateInstance(this.bodyTarget).show() // eslint-disable-line no-undef
  }
}
