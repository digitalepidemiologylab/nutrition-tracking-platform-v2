import { ApplicationController } from 'stimulus-use';
import * as WebAuthnJSON from '@github/webauthn-json';
import { FetchRequest } from '@rails/request.js';

export default class extends ApplicationController {
  static get values() {
    return {
      callback: String,
    };
  }

  async handleSubmit(event) {
    event.preventDefault();
    const { action } = event.target;

    const request = new FetchRequest('post', action);
    const response = await request.perform();

    if (response.ok) {
      const body = await response.text;
      this.create(JSON.parse(body));
    } else {
      this.error(response);
    }
  }

  create(data) {
    WebAuthnJSON.get({ publicKey: data }).then(async (credential) => {
      const request = new FetchRequest(
        'post',
        this.callbackValue,
        { body: JSON.stringify(credential) },
      );
      const response = await request.perform();

      if (response.ok) {
        const responseData = await response.json;
        window.Turbo.visit(responseData.redirect, {
          action: 'replace',
        });
      } else {
        this.error(response);
      }
    }).catch((error) => {
      this.error(error);
    });
  }

  error(event) {
    alert(`Unable to authenticate with passkey.\n${event}`);
  }
}
