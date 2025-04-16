import { ApplicationController } from 'stimulus-use';
import * as WebAuthnJSON from '@github/webauthn-json';
import { FetchRequest } from '@rails/request.js';

export default class extends ApplicationController {
  static get targets() {
    return ['nickname'];
  }

  static get values() {
    return { callback: String };
  }

  async handleSubmit(event) {
    event.preventDefault();
    const { action } = event.target;
    const nickname = this.nicknameTarget.value;
    const request = new FetchRequest('post', action, {
      body: JSON.stringify({
        webauthn_credential: {
          nickname,
        },
      }),
    });
    const response = await request.perform();

    if (response.ok) {
      const body = await response.text;
      this.create(JSON.parse(body));
    } else {
      this.error(response);
    }
  }

  create(data) {
    WebAuthnJSON.create({ publicKey: data }).then(async (credential) => {
      const request = new FetchRequest(
        'post',
        `${this.callbackValue}?nickname=${this.nicknameTarget.value}`,
        { body: JSON.stringify(credential), responseKind: 'turbo-stream' },
      );
      request.perform();
    }).catch((error) => {
      this.error(error);
    });
  }

  error(error) {
    alert('Unable to register Passkey', error);
  }
}
