import { Controller } from '@hotwired/stimulus'

// Updates an input when confirm / unconfirm is clicked.
export default class extends Controller {
  static targets = ['input']

  confirm () {
    this.inputTarget.value = 'true'
  }

  unconfirm () {
    this.inputTarget.value = 'false'
  }
}
