import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["input", "dissertationFile"];

  start(event) {
    const fileType = event.params.type;
    Array.from(this.inputTarget.files).forEach(file => this.uploadFile(file, fileType))
  }


  uploadFile(file, fileType) {
    const url = this.inputTarget.dataset.directUploadUrl;
    const upload = new DirectUpload(file, url, this);

    upload.create((error, blob) => {
      if (error) {
        console.error("There was an error uploading the file.");
      } else {
        this.submitData('0001', blob, fileType);
      }
    })
  }

  async submitData(submissionId, blob, fileType) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const response = await fetch(`/submissions/${submissionId}/attachments`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ file_id: blob.signed_id, file_type: fileType }),
    });

    if (response.ok) {
      const dissertationFile = this.dissertationFileTarget.rows[1];
      dissertationFile.cells[0].innerText = blob.filename;
      dissertationFile.cells[2].innerText = blob.byte_size.toLocaleString();
      dissertationFile.cells[3].innerText = blob.created_at.toLocaleString();
    } else {
      // Handle error
    }
  }
}
