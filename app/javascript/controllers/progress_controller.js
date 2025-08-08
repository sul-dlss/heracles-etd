import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  disableStep (stepNumber) {
    this._toggleCharacterCircle(stepNumber)
  }

  successStep (stepNumber) {
    this._toggleCharacterCircle(stepNumber)
  }

  _toggleCharacterCircle (stepNumber) {
    const stepElement = this.element.querySelector(`#step-${stepNumber}`)
    stepElement.querySelector('.character-circle-disabled').classList.toggle('d-none')
    stepElement.querySelector('.character-circle-success').classList.toggle('d-none')
  }
}
