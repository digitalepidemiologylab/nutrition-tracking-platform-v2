// Self-destructing controller: see https://boringrails.com/articles/self-destructing-stimulus-controllers/

import { ApplicationController } from 'stimulus-use';

export default class extends ApplicationController {
  connect() {
    const annotationElement = this.element.previousElementSibling;
    const elementToFocusId = annotationElement.dataset.annotationFocusValue;
    if (elementToFocusId) {
      const elementToFocus = document.getElementById(elementToFocusId);
      if (elementToFocus) {
        if (elementToFocus.tomselect === undefined) {
          elementToFocus.focus();
        } else {
          const nextInput = elementToFocus
            .closest('.annotation-item')
            .querySelector('input[name="annotation_item[present_quantity]"]');
          if (nextInput) {
            nextInput.focus();
          }
        }
      }
    }
    this.element.remove();
  }
}
