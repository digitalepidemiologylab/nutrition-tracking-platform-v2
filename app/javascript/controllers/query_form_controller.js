import { ApplicationController, useDebounce } from 'stimulus-use';

// Connects to data-controller="query-form"
export default class extends ApplicationController {
  static debounces = [
    {
      name: 'handleSearchChange',
      wait: 500,
    },
  ];

  connect() {
    useDebounce(this);
  }

  handleCountChange(event) {
    event.preventDefault();
    event.target.form.requestSubmit();
  }

  handleSearchChange(event) {
    event.preventDefault();
    event.target.form.requestSubmit();
  }
}
