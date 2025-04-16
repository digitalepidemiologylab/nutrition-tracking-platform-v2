import { Controller } from '@hotwired/stimulus';
import { useTransition } from 'stimulus-use';

export default class extends Controller {
  static get targets() {
    return ['button', 'menu'];
  }

  connect() {
    useTransition(this, {
      element: this.menuTarget,
    });
  }

  move() {
    if (this.menuTarget.classList.contains('hidden')) {
      this.enter();
    } else {
      this.leave();
    }
  }
}
