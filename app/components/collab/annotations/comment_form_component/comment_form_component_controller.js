import { ApplicationController } from 'stimulus-use';

export default class extends ApplicationController {
  static get targets() {
    return ['message'];
  }

  handleChange(event) {
    const { target } = event;
    const existingMessage = this.messageTarget.value;
    const messageToAdd = target.value;
    const newValue = [existingMessage, messageToAdd].filter((v) => v != null && v.trim().length !== 0).join('\n');
    this.messageTarget.value = newValue;
  }
}
