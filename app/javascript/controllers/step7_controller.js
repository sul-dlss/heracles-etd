import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['doneButton', 'licenseCheck', 'ccLicenseSelect']

  connect () {
    this.toggleButton({ target: { value: '' } })
  }

  toggleButton (event) {
    if (this._valid()) {
      this.doneButtonTarget.disabled = false
      this.doneButtonTarget.classList.remove('disabled')
    } else {
      this.doneButtonTarget.disabled = true
      this.doneButtonTarget.classList.add('disabled')
    }
  }

  _valid () {
    return this.licenseCheckTarget.checked && this.ccLicenseSelectTarget.value !== ''
  }
}
