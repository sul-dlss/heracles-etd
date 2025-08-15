import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['supplementalFilesSection']

  // Supplemental files toggle selection
  showSupplementalFilesSection () {
    this.supplementalFilesSectionTarget.classList.remove('d-none')
  }

  // Supplemental files toggle selection
  hideSupplementalFilesSection () {
    this.supplementalFilesSectionTarget.classList.add('d-none')
  }
}
