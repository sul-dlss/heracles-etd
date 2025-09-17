import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['doneButton', 'warning', 'input']

  toggleButton () {
    if (this.abstract.length > 0) {
      this.doneButtonTarget.disabled = false
    } else {
      this.doneButtonTarget.disabled = true
    }
  }

  warnFormatting () {
    const warn = this.abstract.match(/\$.+\$/) || // e.g., $\sim 100\gev$-$1\tev$
      this.abstract.match(/\\[a-zA-Z]+\{.+\}/) // e.g., \cite{p-Jungman:1995df}
    this.warningTarget.classList.toggle('d-none', !warn)
  }

  get abstract () {
    return this.inputTarget.value.trim()
  }

  inputTargetConnected () {
    this.warnFormatting()
  }
}
