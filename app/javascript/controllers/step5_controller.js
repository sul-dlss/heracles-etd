import { Controller } from '@hotwired/stimulus'
import { DirectUpload } from '@rails/activestorage'

export default class extends Controller {
  static targets = ['withSupplementalFiles', 'supplementalFilesSection','supplementalFiles', 'supplementalFilesTable']

  connect () {
    if (this.withSupplementalFilesTarget.checked) {
      this.showSupplementalFilesSection()
    } else {
      this.hideSupplementalFilesSection()
    }
  }

  // Supplemental files toggle selection
  showSupplementalFilesSection () {
    this.supplementalFilesSectionTarget.classList.remove('d-none')
  }

  // Supplemental files toggle selection
  hideSupplementalFilesSection () {
    this.supplementalFilesSectionTarget.classList.add('d-none')
  }

  uploadSupplementalFiles (event) {
    Array.from(this.supplementalFilesTarget.files).forEach(file => this.uploadFile(this.supplementalFilesTarget, this.supplementalFilesTableTarget, file))
    event.preventDefault()
  }

  uploadFile (inputTarget, outputTarget, file) {
    const url = inputTarget.dataset.directUploadUrl
    const upload = new DirectUpload(file, url, this)

    upload.create((error, blob) => {
      if (error) {
        console.error('There was an error uploading the file.')
      } else {
        const pos = outputTarget.rows.length
        let row = outputTarget.insertRow(pos - 1)
        row.innerHTML = `
          <td>${blob.filename}</td>
          <td>${blob.content_type}</td>
          <td>${blob.byte_size.toLocaleString()}</td>
          <td>${blob.created_at.toLocaleString()}</td>
        `
      }
    })
  }
}
