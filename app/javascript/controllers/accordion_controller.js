import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "progress", "submit" ]

  collapse(event) {
    const target = event.currentTarget
    const collapseElement = target.closest(".accordion-collapse")
    bootstrap.Collapse.getOrCreateInstance(collapseElement).hide()

    const accordionItemElement = target.closest(".accordion-item")
    const stepNumberElement = accordionItemElement.querySelector(".step-number")
    stepNumberElement.classList.replace("step-number-disabled", "step-number-success")

    const inProgressBadge = accordionItemElement.querySelector(".badge-in-progress")
    inProgressBadge.classList.add("d-none")

    const completedBadge = accordionItemElement.querySelector(".badge-completed")
    completedBadge.classList.remove("d-none")

    this.progressOutlets.forEach(outlet => outlet.successStep(event.params.step))
    this.submitOutlets.forEach(outlet => outlet.stepDone(event.params.step))
  }

  expand(event) {
    const target = event.currentTarget
    const accordionItemElement = target.closest(".accordion-item")
    const collapseElement = accordionItemElement.querySelector(".accordion-collapse")
    bootstrap.Collapse.getOrCreateInstance(collapseElement).show()

    
    const stepNumberElement = accordionItemElement.querySelector(".step-number")
    stepNumberElement.classList.replace("step-number-success", "step-number-disabled")

    const inProgressBadge = accordionItemElement.querySelector(".badge-in-progress")
    inProgressBadge.classList.remove("d-none")

    const completedBadge = accordionItemElement.querySelector(".badge-completed")
    completedBadge.classList.add("d-none")

    this.progressOutlets.forEach(outlet => outlet.disableStep(event.params.step))
    this.submitOutlets.forEach(outlet => outlet.stepUndone(event.params.step))
  }
}
