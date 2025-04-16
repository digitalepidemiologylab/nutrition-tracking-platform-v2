// Self-destructing controller: see https://boringrails.com/articles/self-destructing-stimulus-controllers/

import { ApplicationController } from 'stimulus-use';

export default class extends ApplicationController {
  static get values() {
    return {
      id: String,
      polygonSetUrl: String,
    };
  }

  static get outlets() {
    return ['annotation'];
  }

  connect() {
    this.annotationOutlet.selectedValue = this.idValue;
    this.annotationOutlet.polygonSetUrlValue = this.polygonSetUrlValue;
    this.element.remove();
  }
}
