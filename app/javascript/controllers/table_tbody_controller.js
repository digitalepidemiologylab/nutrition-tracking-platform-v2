// Self-destructing controller: see https://boringrails.com/articles/self-destructing-stimulus-controllers/

import { ApplicationController } from 'stimulus-use';

export default class extends ApplicationController {
  connect() {
    const table = this.element.closest('table');
    if (table) {
      const thead = table.querySelector('thead');
      if (thead) {
        if (table.querySelectorAll('tbody tr').length > 0) {
          thead.classList.remove('hidden');
        } else {
          thead.classList.add('hidden');
        }
      }
    }
    this.element.remove();
  }
}
