/**
 * Toast System
 * Auto-dismissing notifications, max 1 visible at a time
 */

class ToastManager {
  constructor() {
    this.toast = null;
    this.timeout = null;
    this.init();
  }

  init() {
    this.createToast();
  }

  createToast() {
    this.toast = document.createElement('div');
    this.toast.id = 'global-toast';
    this.toast.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      background: var(--color-surface);
      border: 1px solid var(--color-border);
      border-radius: var(--radius-md);
      box-shadow: var(--shadow-lg);
      padding: var(--space-4);
      min-width: 300px;
      max-width: 500px;
      z-index: 10000;
      display: none;
      align-items: center;
      gap: var(--space-3);
      transform: translateX(100%);
      transition: transform var(--transition-normal);
    `;

    this.toast.innerHTML = `
      <div class="toast-icon" style="font-size: var(--font-size-lg);"></div>
      <div class="toast-message" style="
        flex: 1;
        font-size: var(--font-size-sm);
        color: var(--color-text-primary);
        line-height: var(--line-height-normal);
      "></div>
      <button class="toast-close" style="
        background: none;
        border: none;
        color: var(--color-text-tertiary);
        cursor: pointer;
        padding: var(--space-1);
        font-size: var(--font-size-lg);
        line-height: 1;
      ">×</button>
    `;

    document.body.appendChild(this.toast);

    // Close button
    this.toast.querySelector('.toast-close').addEventListener('click', () => {
      this.hide();
    });
  }

  show(message, type = 'info') {
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout);
    }

    // Update content and styling
    const iconEl = this.toast.querySelector('.toast-icon');
    const messageEl = this.toast.querySelector('.toast-message');

    // Set icon and color based on type
    const typeConfig = {
      success: {
        icon: '✓',
        color: 'var(--color-success)',
        bgIcon: 'rgba(0, 213, 75, 0.1)'
      },
      error: {
        icon: '✕',
        color: 'var(--color-error)',
        bgIcon: 'rgba(255, 59, 48, 0.1)'
      },
      info: {
        icon: 'ℹ',
        color: 'var(--color-info)',
        bgIcon: 'rgba(0, 122, 255, 0.1)'
      }
    };

    const config = typeConfig[type] || typeConfig.info;
    
    iconEl.textContent = config.icon;
    iconEl.style.color = config.color;
    iconEl.style.backgroundColor = config.bgIcon;
    iconEl.style.width = '24px';
    iconEl.style.height = '24px';
    iconEl.style.borderRadius = 'var(--radius-full)';
    iconEl.style.display = 'flex';
    iconEl.style.alignItems = 'center';
    iconEl.style.justifyContent = 'center';

    messageEl.textContent = message;

    // Show toast
    this.toast.style.display = 'flex';
    setTimeout(() => {
      this.toast.style.transform = 'translateX(0)';
    }, 10);

    // Auto-hide after 3 seconds
    this.timeout = setTimeout(() => {
      this.hide();
    }, 3000);
  }

  hide() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }

    this.toast.style.transform = 'translateX(100%)';
    setTimeout(() => {
      this.toast.style.display = 'none';
    }, 250);
  }
}

// Create global toast instance
window.Toast = new ToastManager();

// Export convenience methods
window.toast = {
  success: (message) => window.Toast.show(message, 'success'),
  error: (message) => window.Toast.show(message, 'error'),
  info: (message) => window.Toast.show(message, 'info')
};
