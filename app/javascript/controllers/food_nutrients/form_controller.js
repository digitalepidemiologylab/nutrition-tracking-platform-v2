import { ApplicationController } from 'stimulus-use';

// Connects to data-controller="food-nutrients--form"
export default class extends ApplicationController {
  destroy() {
    this.element.remove();
  }
}
