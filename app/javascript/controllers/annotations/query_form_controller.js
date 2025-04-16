import { ApplicationController } from 'stimulus-use';

// Connects to data-controller="annotations--query-form"
export default class extends ApplicationController {
  handleFilterChange(event) {
    event.preventDefault();
    const { form } = event.target;
    const fullUrl = new URL(form.action);
    // Prepend url query params and let form body params override existing one,
    // then simply submit the form.
    const queryParams = new URL(fullUrl).searchParams;
    queryParams.forEach((value, name) => {
      if (name !== 'annotations_page') {
        const input = document.createElement('input');
        Object.assign(input, { type: 'hidden', value, name });
        form.prepend(input);
      }
    });
    event.target.form.requestSubmit();
  }
}
