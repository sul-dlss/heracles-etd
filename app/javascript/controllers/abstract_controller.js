import { Controller } from '@hotwired/stimulus'

// Maximum allowed length for the abstract sent to datacite when registering DOI
// is 5000 characters.
const MAX_ABSTRACT_LENGTH = 5000

export default class extends Controller {
  static targets = ['doneButton', 'formatting', 'length', 'input']

  toggleButton () {
    if (this.abstract.length > 0 && this.abstract.length <= MAX_ABSTRACT_LENGTH) {
      this.doneButtonTarget.disabled = false
    } else {
      this.doneButtonTarget.disabled = true
      this.warn()
    }
  }

  // The textarea and Done button are in separate forms. Clicking Done blurs the
  // textarea and starts its autosave, but Turbo may cancel that request when the
  // Done form submits. Copy the current abstract into the Done form so the
  // abstract and abstract_provided flag are saved atomically.
  prepareCompletion (event) {
    const form = event.currentTarget.form
    let abstractInput = form.querySelector('input[name="submission[abstract]"]')

    if (!abstractInput) {
      abstractInput = document.createElement('input')
      abstractInput.type = 'hidden'
      abstractInput.name = 'submission[abstract]'
      form.appendChild(abstractInput)
    }

    abstractInput.value = this.inputTarget.value
  }

  warnFormatting () {
    const warn = this.abstract.match(/\$.+\$/) || // e.g., $\sim 100\gev$-$1\tev$
      this.abstract.match(/\\[a-zA-Z]+\{.+\}/) // e.g., \cite{p-Jungman:1995df}
    this.formattingTarget.classList.toggle('d-none', !warn)
  }

  warnLength () {
    const tooLong = this.abstract.length > MAX_ABSTRACT_LENGTH
    this.lengthTarget.classList.toggle('d-none', !tooLong)
  }

  get abstract () {
    return this.inputTarget.value.trim()
  }

  warn () {
    this.warnFormatting()
    this.warnLength()
  }

  inputTargetConnected () {
    this.warn()
  }
}
