/**
 * Modal System
 * Single reusable modal element with focus management
 */

class ModalManager {
  constructor() {
    this.modal = null;
    this.isOpen = false;
    this.init();
  }

  init() {
    // Create modal element once
    this.createModal();
  }

  createModal() {
    this.modal = document.createElement('div');
    this.modal.id = 'global-modal';
    this.modal.className = 'modal-overlay';
    this.modal.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: none;
      align-items: center;
      justify-content: center;
      z-index: 9999;
      padding: 20px;
    `;

    this.modal.innerHTML = `
      <div class="modal-content" style="
        background: var(--color-surface);
        border: 1px solid var(--color-border);
        border-radius: var(--radius-lg);
        max-width: 500px;
        width: 100%;
        max-height: 90vh;
        overflow-y: auto;
        padding: 0;
      ">
        <div class="modal-header" style="
          padding: var(--space-6);
          border-bottom: 1px solid var(--color-border);
        ">
          <h3 class="modal-title" style="
            margin: 0;
            font-size: var(--font-size-xl);
            font-weight: var(--font-weight-semibold);
            color: var(--color-text-primary);
          "></h3>
        </div>
        <div class="modal-body" style="
          padding: var(--space-6);
          color: var(--color-text-secondary);
          line-height: var(--line-height-relaxed);
        "></div>
        <div class="modal-footer" style="
          padding: var(--space-6);
          border-top: 1px solid var(--color-border);
          display: flex;
          gap: var(--space-3);
          justify-content: flex-end;
        "></div>
      </div>
    `;

    document.body.appendChild(this.modal);

    // Close on overlay click
    this.modal.addEventListener('click', (e) => {
      if (e.target === this.modal) {
        this.hide();
      }
    });

    // Close on Escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.isOpen) {
        this.hide();
      }
    });
  }

  show(options) {
    const {
      title = 'Modal',
      message = '',
      primaryText = 'OK',
      onPrimary = null,
      secondaryText = null,
      onSecondary = null
    } = options;

    // Update content
    const titleEl = this.modal.querySelector('.modal-title');
    const bodyEl = this.modal.querySelector('.modal-body');
    const footerEl = this.modal.querySelector('.modal-footer');

    titleEl.textContent = title;
    bodyEl.textContent = message;

    // Clear and rebuild footer
    footerEl.innerHTML = '';

    if (secondaryText) {
      const secondaryBtn = document.createElement('button');
      secondaryBtn.className = 'btn btn-secondary';
      secondaryBtn.textContent = secondaryText;
      secondaryBtn.addEventListener('click', () => {
        if (onSecondary) onSecondary();
        this.hide();
      });
      footerEl.appendChild(secondaryBtn);
    }

    const primaryBtn = document.createElement('button');
    primaryBtn.className = 'btn btn-primary';
    primaryBtn.textContent = primaryText;
    primaryBtn.addEventListener('click', () => {
      if (onPrimary) onPrimary();
      this.hide();
    });
    footerEl.appendChild(primaryBtn);

    // Show modal
    this.modal.style.display = 'flex';
    this.isOpen = true;

    // Focus primary button
    setTimeout(() => {
      primaryBtn.focus();
    }, 100);

    // Prevent body scroll
    document.body.style.overflow = 'hidden';
  }

  hide() {
    this.modal.style.display = 'none';
    this.isOpen = false;
    document.body.style.overflow = '';
  }
}

// Create global modal instance
window.Modal = new ModalManager();

// Export convenience functions
window.showModal = (options) => window.Modal.show(options);
window.hideModal = () => window.Modal.hide();
