import { ApplicationController } from 'stimulus-use';
import TomSelect from 'tom-select';
import i18n from '../../i18n';

export default class extends ApplicationController {
  static get targets() {
    return ['foodSetsSelect'];
  }

  connect() {
    if (this.hasFoodSetsSelectTarget) {
      this.enableTomSelect();
    }
  }

  enableTomSelect() {
    const { url } = this.foodSetsSelectTarget.dataset;
    new TomSelect(this.foodSetsSelectTarget, { /* eslint-disable-line no-new */
      valueField: 'id',
      labelField: 'name',
      searchField: 'name',
      preload: 'focus',
      maxOptions: 10000,
      plugins: ['dropdown_input', 'virtual_scroll', 'remove_button'],
      firstUrl(query) {
        return `${url}?query=${encodeURIComponent(query)}&page=1`;
      },
      load(query, callback) {
        const queryUrl = this.getUrl(query);
        fetch(queryUrl)
          .then((response) => response.json())
          .then((json) => {
            if (json.meta.next > json.meta.page) {
              const nextUrl = `${url}?query=${encodeURIComponent(query)}&page=${json.meta.next}`;
              this.setNextUrl(query, nextUrl);
            }

            const items = json.data.map((item) => ({ id: item.id, ...item.attributes }));
            callback(items);
          }).catch(() => {
            callback();
          });
      },
      render: {
        option(item, escape) {
          return `<div>${escape(item.name)}</div>`;
        },
        item(item, escape) {
          return `<div>${escape(item.name)}</div>`;
        },
        loading_more() {
          return `<div>${i18n.tomSelect.loading}</div>`;
        },
        no_results() {
          return `<div class="no-results">${i18n.tomSelect.noResults}</div>`;
        },
        no_more_results() {
          return `<div>${i18n.tomSelect.noMoreResults}</div>`;
        },
      },
    });
  }
}
