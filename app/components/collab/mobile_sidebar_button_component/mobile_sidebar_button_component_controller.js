import { Controller } from '@hotwired/stimulus';
import { useDispatch } from 'stimulus-use';

export default class extends Controller {
  connect() {
    useDispatch(this);
  }

  open() {
    this.dispatch('open');
  }
}
