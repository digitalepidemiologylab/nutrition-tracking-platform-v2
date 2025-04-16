// Self-destructing controller: see https://boringrails.com/articles/self-destructing-stimulus-controllers/

import { ApplicationController } from 'stimulus-use';

export default class extends ApplicationController {
  static get outlets() {
    return ['annotation'];
  }

  connect() {
    this.annotationOutlets.forEach((annotation) => {
      annotation.toggleButtons();
    });
    this.element.remove();
  }
}
