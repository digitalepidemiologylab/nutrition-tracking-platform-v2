import { ApplicationController } from 'stimulus-use';
import TomSelect from 'tom-select';

export default class extends ApplicationController {
  static get targets() {
    return ['foodListsSelect'];
  }

  connect() {
    if (this.hasFoodListsSelectTarget) {
      this.enableTomSelect();
    }
  }

  enableTomSelect() {
    new TomSelect(this.foodListsSelectTarget, { /* eslint-disable-line no-new */
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
      preload: 'focus',
      plugins: ['dropdown_input', 'remove_button'],
      render: {
        option(item, escape) {
          return `<div>${escape(item.name)}</div>`;
        },
        item(item, escape) {
          return `<div>${escape(item.name)}</div>`;
        },
      },
    });
  }
}
