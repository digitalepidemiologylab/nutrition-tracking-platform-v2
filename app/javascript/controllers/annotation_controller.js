import { ApplicationController } from 'stimulus-use';
import { post, destroy } from '@rails/request.js';

export default class extends ApplicationController {
  static get targets() {
    return [
      'clearPolygonSetLink',
      'form',
      'hidePolygonsLink',
    ];
  }

  static get outlets() {
    return ['canvas'];
  }

  static get values() {
    return {
      selected: String,
      focus: String,
      polygonSetUrl: String,
    };
  }

  static get classes() {
    return ['hidden'];
  }

  connect() {
    window.addEventListener('click', (e) => { this.deselectAll(e); }, false);
  }

  deselectAll(e) {
    const { target } = e;
    if (
      ![null, undefined, ''].includes(this.selectedValue)
        && !target.closest('canvas')
        && !target.closest('.annotation-item')
        && !target.closest('#annotation_items--title')
    ) {
      this.selectedValue = '';
      this.polygonSetUrlValue = '';
    }
  }

  selectItem(event) {
    // target is not the Destroy link
    const { target } = event;
    if (!target.closest('a[data-turbo-method="delete"]')) {
      const item = target.closest('div.annotation-item');
      const { id, polygonSetUrl } = item.dataset;
      if (this.selectedValue !== id) {
        this.selectedValue = id;
        this.polygonSetUrlValue = polygonSetUrl;
      }
    }
    if (['input', 'select'].includes(target.tagName.toLowerCase())) {
      this.focusValue = target.id;
    }
  }

  selectedValueChanged() {
    this.selectItemById(this.selectedValue);
  }

  selectItemById(id) {
    if (this.hasCanvasOutlet) {
      this.canvasOutlet.setAnnotationItemId(this.selectedValue, this.polygonSetUrlValue);
    }
    this.formTargets.forEach((formTarget) => {
      if (formTarget.dataset.id === id && formTarget.getAttribute('data-selected') !== 'selected') {
        formTarget.setAttribute('selected', 'selected');
      } else {
        formTarget.removeAttribute('selected');
      }
    });
    if (this.hasClearPolygonSetLinkTarget) {
      this.clearPolygonSetLinkTarget.disabled = [null, undefined, ''].includes(this.selectedValue);
    }
  }

  hidePolygons(event) {
    event.preventDefault();
    if (this.hasCanvasOutlet) {
      const canvas = this.canvasOutlet.element;
      const link = this.hidePolygonsLinkTarget;
      if (canvas.classList.contains(this.hiddenClass)) {
        canvas.classList.remove(this.hiddenClass);
        link.innerText = link.dataset.i18nHide;
      } else {
        canvas.classList.add(this.hiddenClass);
        link.innerText = link.dataset.i18nShow;
      }
    }
  }

  destroyPolygons(event) {
    event.preventDefault();
    if (this.hasCanvasOutlet) {
      this.canvasOutlet.destroyPolygons();
    }
  }

  toggleButtons() {
    const mergeButton = this.element.querySelector('#merge_annotation_items');
    const destroyButton = this.element.querySelector('#destroy_annotation_items');
    const elements = this
      .element
      .querySelectorAll('input[name="annotations_selected_annotation_items[annotation_item_ids]"]:checked');
    if (elements.length > 1) {
      mergeButton.disabled = false;
    } else {
      mergeButton.disabled = true;
    }
    if (elements.length > 0) {
      destroyButton.disabled = false;
    } else {
      destroyButton.disabled = true;
    }
  }

  mergeAnnotationItems(event) {
    event.preventDefault();
    const form = event.target.closest('form');
    const confirmMessage = form.dataset.turboConfirm;
    if (window.confirm(confirmMessage)) {
      const { action } = form;
      const elements = this
        .element
        .querySelectorAll('input[name="annotations_selected_annotation_items[annotation_item_ids]"]:checked');
      const values = [];
      elements.forEach((element) => {
        values.push(element.value);
      });

      post(action, {
        body: {
          annotations_annotation_items_merge_form: {
            annotation_item_ids: values,
          },
        },
        responseKind: 'turbo-stream',
      });
    }
  }

  destroyAnnotationItems(event) {
    event.preventDefault();
    const form = event.target.closest('form');
    const confirmMessage = form.dataset.turboConfirm;
    if (window.confirm(confirmMessage)) {
      const { action } = form;
      const elements = this
        .element
        .querySelectorAll('input[name="annotations_selected_annotation_items[annotation_item_ids]"]:checked');
      const values = [];
      elements.forEach((element) => {
        values.push(element.value);
      });

      destroy(action, {
        body: {
          annotations_annotation_items_destroy_form: {
            annotation_item_ids: values,
          },
        },
        responseKind: 'turbo-stream',
      });
    }
  }
}
