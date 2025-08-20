import { Controller } from '@hotwired/stimulus'

// This controller allows for setting the focus after a form submission.
// It requires a permanent div that stores the state between renders: <div id="focus" data-turbo-permanent="true" data-focus-target="permanent"></div>
// restoreFocus() should be invoked on turbo:render: data-action="turbo:render@window->focus#restoreFocus"
// The id of the element that should receive focus should be set before form submission: data-action="click->focus#saveFocus" data-focus-id-param="step-1-edit"
export default class extends Controller {
  static targets = ['permanent']

  restoreFocus () {
    const focusId = this.permanentTarget.dataset.focusId
    if (!focusId) return
    const focusElement = document.getElementById(focusId)
    if (!focusElement) return

    focusElement.focus()
    delete this.permanentTarget.dataset.focusId
  }

  saveFocus (event) {
    this.permanentTarget.dataset.focusId = event.params.id
  }
}
