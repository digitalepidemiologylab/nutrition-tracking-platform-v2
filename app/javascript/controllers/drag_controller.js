import { ApplicationController } from 'stimulus-use';
import { patch } from '@rails/request.js';

const dataResourceId = 'data-resource-id';
const dataUrl = 'data-url';
const dataParent = 'data-parent';
let url;
let resourceId;
let newPostion;

export default class extends ApplicationController {
  dragStart(event) {
    resourceId = event.target.getAttribute(dataResourceId);
    url = event.target.getAttribute(dataUrl);
    // eslint-disable-next-line no-param-reassign
    event.dataTransfer.effectAllowed = 'move';
  }

  dragOver(event) {
    event.preventDefault();
    return true;
  }

  dragEnter(event) {
    event.preventDefault();
  }

  dragLeave(event) {
    event.preventDefault();
  }

  dragDrop(event) {
    event.preventDefault();
    const parentId = event.target.getAttribute(dataParent);
    const dropTarget = this.findDropTarget(event.target, parentId);
    const draggedItem = document.querySelector(`[data-resource-id="${resourceId}"]`);
    if (draggedItem == null || dropTarget == null) {
      return true;
    }
    this.setNewPosition(dropTarget, draggedItem);
    newPostion = [...this.element.parentElement.children].indexOf(draggedItem);
    return true;
  }

  async dragEnd(event) {
    event.preventDefault();
    if (resourceId == null || newPostion == null) {
      return true;
    }
    await patch(url, {
      body: {
        position: newPostion + 1,
      },
      responseKind: 'turbo-stream',
    });
    newPostion = null;
    resourceId = null;
    return true;
  }

  findDropTarget(target, parentId) {
    if (target == null) {
      return null;
    }
    if (target === parentId) {
      return null;
    }
    if (target.classList.contains('draggable')) {
      return target;
    }
    return this.findDropTarget(target.parentElement, parentId);
  }

  setNewPosition(dropTarget, draggedItem) {
    const positionComparison = dropTarget.compareDocumentPosition(draggedItem);
    if (positionComparison && Node.DOCUMENT_POSITION_FOLLOWING) {
      if (positionComparison === Node.DOCUMENT_POSITION_FOLLOWING) {
        this.setBefore(dropTarget, draggedItem);
      } else {
        this.setAfter(dropTarget, draggedItem);
      }
    }
  }

  setBefore(dropTarget, draggedItem) {
    dropTarget.insertAdjacentElement('beforebegin', draggedItem);
  }

  setAfter(dropTarget, draggedItem) {
    dropTarget.insertAdjacentElement('afterend', draggedItem);
  }
}
