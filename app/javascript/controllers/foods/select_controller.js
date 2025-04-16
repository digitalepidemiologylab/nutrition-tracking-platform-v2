import { ApplicationController } from 'stimulus-use';
import TomSelect from 'tom-select';
import i18n from '../../i18n';

export default class extends ApplicationController {
  static get targets() {
    return ['foodSelect'];
  }

  connect() {
    if (this.hasFoodSelectTarget) {
      this.enableTomSelect();
    }
  }

  enableTomSelect() {
    const { url, preload } = this.foodSelectTarget.dataset;
    if (!this.foodSelectTarget.classList.contains('tomselected')) {
      new TomSelect(this.foodSelectTarget, { /* eslint-disable-line no-new */
        valueField: 'id',
        labelField: 'name',
        searchField: 'name',
        preload,
        maxOptions: 10000,
        plugins: [
          'dropdown_input',
          'virtual_scroll',
        ],
        onFocus() {
          const controlledElement = this.control_input.closest('div.annotation-item');
          controlledElement.dispatchEvent(new Event('click'));
          this.input.dispatchEvent(new Event('focus'));
        },
        firstUrl(query) {
          const formattedUrl = new URL(url);
          formattedUrl.searchParams.append('query', encodeURIComponent(query));
          formattedUrl.searchParams.append('page', 1);
          return formattedUrl.href;
        },
        load(query, callback) {
          const queryUrl = this.getUrl(query);
          const formattedUrl = new URL(queryUrl);

          fetch(queryUrl)
            .then((response) => response.json())
            .then((json) => {
              if (json.meta.next > json.meta.page) {
                formattedUrl.searchParams.append('query', encodeURIComponent(query));
                formattedUrl.searchParams.set('page', json.meta.next);
                this.setNextUrl(query, formattedUrl.href);
              }
              const items = json.data.map((item) => ({ id: item.id, ...item.attributes }));
              callback(items);
            }).catch(() => {
              callback();
            });
        },
        render: {
          option(item, escape) {
            return `<div
              data-unit_id="${item.unit_id || item.unitId}"
              data-portion_quantity="${item.portion_quantity || item.portionQuantity}"
            >${escape(item.name)}</div>`;
          },
          item(item, escape) {
            return `<div
              data-unit-id="${item.unit_id || item.unitId}"
              data-portion-quantity="${item.portion_quantity || item.portionQuantity}"
            >${escape(item.name)}</div>`;
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
}
