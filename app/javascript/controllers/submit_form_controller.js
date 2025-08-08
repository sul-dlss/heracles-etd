import { Controller } from '@hotwired/stimulus'

// This manages the expand/collapse and related functionality of the submitter form.
export default class extends Controller {
  static outlets = ['submit']
  static targets = ['collapse']

  collapseTargetConnected (element) {
    element.addEventListener('show.bs.collapse', this.expand.bind(this))
    element.addEventListener('hide.bs.collapse', this.collapse.bind(this))
  }

  collapseTargetDisconnected (element) {
    element.removeEventListener('show.bs.collapse', this.expand.bind(this))
    element.removeEventListener('hide.bs.collapse', this.collapse.bind(this))
  }

  collapse (event) {
    const target = event.currentTarget

    const collapseItemElement = target.closest('.collapse-item')
    this.toggleCollapseButton(collapseItemElement, false)

    const characterCircleElement = collapseItemElement.querySelector('.character-circle')
    characterCircleElement.classList.replace('character-circle-disabled', 'character-circle-success')

    const stepNumber = collapseItemElement.dataset.stepNumber

    this.submitOutlets.forEach(outlet => outlet.stepDone(stepNumber))
  }

  expand (event) {
    const target = event.currentTarget
    const collapseItemElement = target.closest('.collapse-item')
    this.toggleCollapseButton(collapseItemElement, true)

    const characterCircleElement = collapseItemElement.querySelector('.character-circle')
    characterCircleElement.classList.replace('character-circle-success', 'character-circle-disabled')

    const stepNumber = collapseItemElement.dataset.stepNumber

    this.submitOutlets.forEach(outlet => outlet.stepUndone(stepNumber))
  }

  toggleCollapseButton (collapseItemElement, disabled) {
    const buttonElement = collapseItemElement.querySelector('.collapse-header button')
    buttonElement.disabled = disabled
  }
}
