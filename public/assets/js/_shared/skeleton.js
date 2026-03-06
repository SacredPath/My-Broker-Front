/**
 * Skeleton Loading System
 * Renders skeleton states and empty states
 */

class SkeletonManager {
  /**
   * Render skeleton list items
   * @param {HTMLElement} container - Container to render in
   * @param {number} rows - Number of skeleton rows
   */
  renderSkeletonList(container, rows = 6) {
    if (!container) return;

    const skeletonHTML = Array.from({ length: rows }, () => `
      <div class="list-item skeleton-item">
        <div style="display: flex; align-items: center; gap: var(--space-4);">
          <div class="skeleton skeleton-avatar"></div>
          <div style="flex: 1;">
            <div class="skeleton skeleton-text" style="width: 60%;"></div>
            <div class="skeleton skeleton-text small" style="width: 40%;"></div>
          </div>
          <div class="skeleton skeleton-text" style="width: 80px; height: 32px;"></div>
        </div>
      </div>
    `).join('');

    container.innerHTML = skeletonHTML;
  }

  /**
   * Render skeleton cards
   * @param {HTMLElement} container - Container to render in
   * @param {number} count - Number of skeleton cards
   */
  renderSkeletonCards(container, count = 3) {
    if (!container) return;

    const skeletonHTML = Array.from({ length: count }, () => `
      <div class="card skeleton-card">
        <div class="skeleton skeleton-text" style="width: 40%; margin-bottom: var(--space-4);"></div>
        <div class="skeleton skeleton-text" style="width: 100%; margin-bottom: var(--space-2);"></div>
        <div class="skeleton skeleton-text small" style="width: 80%; margin-bottom: var(--space-4);"></div>
        <div style="display: flex; justify-content: space-between;">
          <div class="skeleton skeleton-text" style="width: 60px; height: 24px;"></div>
          <div class="skeleton skeleton-text" style="width: 80px; height: 32px;"></div>
        </div>
      </div>
    `).join('');

    container.innerHTML = skeletonHTML;
  }

  /**
   * Render empty state
   * @param {HTMLElement} container - Container to render in
   * @param {Object} options - Empty state options
   */
  renderEmpty(container, options = {}) {
    if (!container) return;

    const {
      title = 'No data found',
      body = 'There are no items to display at this time.',
      actionText = null,
      onAction = null
    } = options;

    const actionHTML = actionText ? `
      <button class="btn btn-primary empty-state-action" onclick="window.skeletonEmptyAction && window.skeletonEmptyAction()">
        ${actionText}
      </button>
    ` : '';

    const emptyHTML = `
      <div class="empty-state">
        <div class="empty-state-icon">📭</div>
        <h2 class="empty-state-title">${title}</h2>
        <p class="empty-state-body">${body}</p>
        ${actionHTML}
      </div>
    `;

    container.innerHTML = emptyHTML;

    // Store action handler globally for onclick
    if (onAction) {
      window.skeletonEmptyAction = onAction;
    }
  }

  /**
   * Render error state
   * @param {HTMLElement} container - Container to render in
   * @param {Object} options - Error state options
   */
  renderError(container, options = {}) {
    if (!container) return;

    const {
      title = 'Something went wrong',
      body = 'We encountered an error while loading this content.',
      actionText = 'Try again',
      onAction = null
    } = options;

    const errorHTML = `
      <div class="error-state">
        <div class="error-state-icon">⚠️</div>
        <h2 class="error-state-title">${title}</h2>
        <p class="error-state-body">${body}</p>
        <button class="btn btn-primary error-state-action" onclick="window.skeletonErrorAction && window.skeletonErrorAction()">
          ${actionText}
        </button>
      </div>
    `;

    container.innerHTML = errorHTML;

    // Store action handler globally for onclick
    if (onAction) {
      window.skeletonErrorAction = onAction;
    }
  }

  /**
   * Clear container
   * @param {HTMLElement} container - Container to clear
   */
  clear(container) {
    if (!container) return;
    container.innerHTML = '';
  }
}

// Create global skeleton instance
window.Skeleton = new SkeletonManager();

// Export convenience methods
window.renderSkeletonList = (container, rows) => window.Skeleton.renderSkeletonList(container, rows);
window.renderSkeletonCards = (container, count) => window.Skeleton.renderSkeletonCards(container, count);
window.renderEmpty = (container, options) => window.Skeleton.renderEmpty(container, options);
window.renderError = (container, options) => window.Skeleton.renderError(container, options);
