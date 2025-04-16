import { ApplicationController } from 'stimulus-use';
import { patch } from '@rails/request.js';

export default class extends ApplicationController {
  async handleChange() {
    const form = this.element.closest('form');
    const url = form.action;
    const formData = new FormData(form);

    await patch(url, {
      body: formData,
      responseKind: 'turbo-stream',
    });
  }
}
