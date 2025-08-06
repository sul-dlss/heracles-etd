import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  disableStep(stepNumber) {
    console.log("disableStep", stepNumber)
    const stepElement = this.element.querySelector(`#${stepNumber}`)
    stepElement.querySelector(".step-number-disabled").classList.remove('d-none')
    stepElement.querySelector(".step-number-success").classList.add('d-none')
  }

  successStep(stepNumber) {
    console.log("successStep", stepNumber)
    const stepElement = this.element.querySelector(`#${stepNumber}`)
    stepElement.querySelector(".step-number-disabled").classList.add('d-none')
    stepElement.querySelector(".step-number-success").classList.remove('d-none')
  }
}