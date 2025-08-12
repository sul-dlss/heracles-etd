import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["input", "dissertationFile"];

  start(e) {
    console.log("DirectUploadsController start method called");
    Array.from(this.inputTarget.files).forEach(file => this.uploadFile(file))
  }


  uploadFile(file) {
    const url = this.inputTarget.dataset.directUploadUrl;
    const upload = new DirectUpload(file, url, this);

    upload.create((error, blob) => {
      if (error) {
        console.error("There was an error uploading the file.");
      } else {
        // this.createHiddenInput(blob);
        // console.log(blob)
        const dissertationFile = this.dissertationFileTarget.rows[1];
        dissertationFile.cells[0].innerText = blob.filename;
        dissertationFile.cells[2].innerText = blob.byte_size.toLocaleString();
        dissertationFile.cells[3].innerText = blob.created_at.toLocaleString();
        // this.element.requestSubmit();
      }
    })
  }}
