/**
 * Theme Management
 * Handles dark/light mode toggle with localStorage persistence
 */

class ThemeManager {
  constructor() {
    this.storageKey = 'theme';
    this.init();
  }

  init() {
    // Load saved theme or default to dark
    const savedTheme = localStorage.getItem(this.storageKey);
    const theme = savedTheme || 'dark';
    
    // Apply theme (this will log the theme)
    this.setTheme(theme);
    
    // Setup toggle in dropdown
    this.setupToggle();
  }

  setTheme(theme) {
    const html = document.documentElement;
    
    // Remove existing theme classes
    html.classList.remove('theme-dark', 'theme-light');
    
    // Add new theme class
    html.classList.add(`theme-${theme}`);
    
    // Save to localStorage
    localStorage.setItem(this.storageKey, theme);
    
    // Update toggle button text
    this.updateToggleText(theme);
    
    console.log('Theme changed to:', theme);
  }

  toggle() {
    const currentTheme = localStorage.getItem(this.storageKey) || 'dark';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    this.setTheme(newTheme);
  }

  setupToggle() {
    // Add toggle to dropdown menu
    const dropdown = document.getElementById('user-dropdown');
    if (!dropdown) return;

    // Find the divider before the logout button
    const logoutBtn = document.getElementById('logout-btn');
    const divider = document.createElement('div');
    divider.className = 'dropdown-divider';
    
    const toggleItem = document.createElement('button');
    toggleItem.className = 'dropdown-item';
    toggleItem.id = 'theme-toggle-btn';
    toggleItem.innerHTML = `
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="5"></circle>
        <line x1="12" y1="1" x2="12" y2="3"></line>
        <line x1="12" y1="21" x2="12" y2="23"></line>
        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
        <line x1="1" y1="12" x2="3" y2="12"></line>
        <line x1="21" y1="12" x2="23" y2="12"></line>
        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
      </svg>
      <span id="theme-toggle-text">Light mode</span>
    `;

    toggleItem.addEventListener('click', () => this.toggle());

    // Insert before logout button
    if (logoutBtn) {
      logoutBtn.parentNode.insertBefore(divider, logoutBtn);
      logoutBtn.parentNode.insertBefore(toggleItem, logoutBtn);
    }

    // Update initial text
    this.updateToggleText(localStorage.getItem(this.storageKey) || 'dark');
  }

  updateToggleText(theme) {
    const text = document.getElementById('theme-toggle-text');
    if (text) {
      text.textContent = theme === 'dark' ? 'Light mode' : 'Dark mode';
    }
  }
}

// Initialize theme manager
window.ThemeManager = new ThemeManager();
