import { Controller } from '@hotwired/stimulus'

// Forces the reload of a turbo frame when it becomes visible in the viewport.
export default class extends Controller {
  connect () {
    this.observer = new IntersectionObserver(entries => { // eslint-disable-line no-undef
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.element.reload()
        }
      })
    })
    this.observer.observe(this.element)
  }

  disconnect () {
    if (this.observer) this.observer.disconnect()
  }
}
