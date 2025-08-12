import { Controller } from '@hotwired/stimulus'

// This manages the expand/collapse and related functionality of the submitter form.
export default class extends Controller {
  static outlets = ['submit', 'progress']
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
    const target = event.target
    // This filters out collapses that are nested inside a step collapse.
    if (!target.classList.contains('collapse-step')) return

    const collapseItemElement = target.closest('.collapse-item')
    this._toggleCollapseButton(collapseItemElement, false)
    this._toggleBadges(collapseItemElement)
    this._toggleCharacterCircle(collapseItemElement)

    const stepNumber = collapseItemElement.dataset.stepNumber
    this.submitOutlets.forEach(outlet => outlet.stepDone(stepNumber))
    this.progressOutlets.forEach(outlet => outlet.successStep(stepNumber))
  }

  expand (event) {
    const target = event.target
    // This filters out collapses that are nested inside a step collapse.
    if (!target.classList.contains('collapse-step')) return

    const collapseItemElement = target.closest('.collapse-item')
    this._toggleCollapseButton(collapseItemElement, true)
    this._toggleBadges(collapseItemElement)
    this._toggleCharacterCircle(collapseItemElement)

    const stepNumber = collapseItemElement.dataset.stepNumber
    this.submitOutlets.forEach(outlet => outlet.stepUndone(stepNumber))
    this.progressOutlets.forEach(outlet => outlet.disableStep(stepNumber))
  }

  _toggleCollapseButton (collapseItemElement, disabled) {
    const buttonElement = collapseItemElement.querySelector('.collapse-header button')
    buttonElement.disabled = disabled
  }

  _toggleBadges (collapseItemElement) {
    const inProgressBadge = collapseItemElement.querySelector('.badge-in-progress')
    inProgressBadge.classList.toggle('d-none')

    const completedBadge = collapseItemElement.querySelector('.badge-completed')
    completedBadge.classList.toggle('d-none')
  }

  _toggleCharacterCircle (collapseItemElement) {
    const characterCircleElement = collapseItemElement.querySelector('.character-circle')
    characterCircleElement.classList.toggle('character-circle-disabled')
    characterCircleElement.classList.toggle('character-circle-success')
  }
}
