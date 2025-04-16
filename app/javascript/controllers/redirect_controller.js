// Self-destructing controller: see https://boringrails.com/articles/self-destructing-stimulus-controllers/

import { ApplicationController } from 'stimulus-use';

export default class extends ApplicationController {
  static get values() {
    return {
      url: String,
    };
  }

  connect() {
    window.Turbo.visit(this.urlValue, {
      action: 'replace',
    });
  }
}
