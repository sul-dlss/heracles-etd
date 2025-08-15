import { Controller } from '@hotwired/stimulus'
import { DirectUpload } from '@rails/activestorage'

export default class extends Controller {
  static targets = ['supplementalFilesSection', 'dissertationFile', 'dissertationFileTable', 'supplementalFiles', 'supplementalFileTable']

  // Supplemental files toggle selection
  showSupplementalFilesSection () {
    this.supplementalFilesSectionTarget.classList.remove('d-none')
  }

  // Supplemental files toggle selection
  hideSupplementalFilesSection () {
    this.supplementalFilesSectionTarget.classList.add('d-none')
  }

  uploadDissertationFile (event) {
    Array.from(this.dissertationFileTarget.files).forEach(file => this.uploadFile(this.dissertationFileTarget, this.dissertationFileTableTarget, file, 0))
    event.preventDefault()
  }

  uploadSupplementalFiles (event) {
    Array.from(this.supplementalFilesTarget.files).forEach(file => this.uploadFile(this.supplementalFilesTarget, this.supplementalFileTableTarget, file, 1))
    event.preventDefault()
  }

  uploadFile (inputTarget, outputTarget, file, posOffset) {
    const url = inputTarget.dataset.directUploadUrl
    const upload = new DirectUpload(file, url, this)

    upload.create((error, blob) => {
      if (error) {
        console.error('There was an error uploading the file.')
      } else {
        console.log(blob)
        const pos = outputTarget.rows.length
        outputTarget.insertRow(pos - posOffset).innerHTML = `
          <td>${blob.filename}</td>
          <td>${blob.content_type}</td>
          <td>${blob.byte_size.toLocaleString()}</td>
          <td>${blob.created_at.toLocaleString()}</td>
        `
      }
    })
  }
}
