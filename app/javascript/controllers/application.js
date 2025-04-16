import { Application } from '@hotwired/stimulus';
import tippy from 'tippy.js';

const application = Application.start();

// Configure Stimulus development experience
application.warnings = true;
application.debug = false;
window.Stimulus = application;

export { application }; // eslint-disable-line import/prefer-default-export

document.addEventListener('turbo:load', () => {
  tippy('[data-tippy-content]');
});

document.addEventListener('clipboard-copy', (e) => {
  const button = e.target;
  const { copiedText } = button.dataset;

  if (copiedText !== undefined && button.innerText !== copiedText) {
    const originalText = button.innerText;
    button.innerText = copiedText;

    setTimeout(() => { button.innerText = originalText; }, 1000);
  }
});
