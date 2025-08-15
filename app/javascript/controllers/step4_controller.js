import { Controller } from '@hotwired/stimulus'
import { DirectUpload } from '@rails/activestorage'

export default class extends Controller {
  static targets = ['dissertationFile', 'dissertationFileTable']

  uploadDissertationFile (event) {
    this.uploadFile(this.dissertationFileTarget, this.dissertationFileTableTarget, event.target.files[0])
    event.preventDefault()
  }

  uploadFile (inputTarget, outputTarget, file) {
    const url = inputTarget.dataset.directUploadUrl
    const upload = new DirectUpload(file, url, this)

    upload.create((error, blob) => {
      if (error) {
        console.error('There was an error uploading the file.')
      } else {
        outputTarget.rows[1].innerHTML = `
          <td>${blob.filename}</td>
          <td>${blob.content_type}</td>
          <td>${blob.byte_size.toLocaleString()}</td>
          <td>${blob.created_at.toLocaleString()}</td>
        `
      }
    })
  }
}
