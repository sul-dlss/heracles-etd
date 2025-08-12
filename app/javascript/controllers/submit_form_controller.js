import { Controller } from '@hotwired/stimulus'

// This manages the expand/collapse and related functionality of the submitter form.
export default class extends Controller {
  toggle (event) {
    const target = event.target

    // Toggle the edit button
    const collapseItemElement = target.closest('.collapse-item')
    const buttonElement = collapseItemElement.querySelector('.btn-edit')
    buttonElement.classList.toggle('d-none')

    const collapseElement = document.querySelector(target.dataset.bsTarget)
    const collapse = bootstrap.Collapse.getOrCreateInstance(collapseElement) // eslint-disable-line no-undef
    collapse.toggle()
  }

  toggleAndSubmit (event) {
    const target = event.target
    const collapseElement = document.querySelector(target.dataset.bsTarget)

    // Adding event listeners so that the form is submitted once the collapse is complete.
    const handler = function () {
      // Remove itself
      collapseElement.removeEventListener('shown.bs.collapse', handler)
      collapseElement.removeEventListener('hidden.bs.collapse', handler)

      this.toggleDone()
    }.bind(this)
    collapseElement.addEventListener('shown.bs.collapse', handler)
    collapseElement.addEventListener('hidden.bs.collapse', handler)

    this.toggle(event)
  }

  toggleDone () {
    this.element.requestSubmit()
  }
}
