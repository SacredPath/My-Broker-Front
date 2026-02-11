/**
 * Global App Shell Initializer
 * One shared initializer for all dashboard pages
 */

// Global guard to prevent double initialization
if (window.__APP_SHELL_INIT__) {
  // Already initialized, do nothing
} else {
  window.__APP_SHELL_INIT__ = true;

  /**
   * Initialize app shell - theme, dropdown, logout, notifications
   */
  function initAppShell() {
    console.log('🚀 Initializing app shell...');
    
    // Apply theme immediately
    applyTheme();
    
    // Wire dropdown menu
    wireDropdowns();
    
    // Wire notifications bell
    wireNotifications();
    
    console.log('✅ App shell initialized');
  }

  /**
   * Apply theme from localStorage
   */
  function applyTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    const html = document.documentElement;
    
    // Apply theme using data-attribute
    html.setAttribute('data-theme', savedTheme);
    
    console.log(`🎨 Applied theme: ${savedTheme}`);
  }

  /**
   * Wire dropdown menu with event delegation
   */
  function wireDropdowns() {
    // Setup event delegation for dropdowns and actions
    document.addEventListener('click', (e) => {
      // Handle dropdown trigger
      const trigger = e.target.closest('[data-menu-trigger]');
      if (trigger) {
        e.preventDefault();
        e.stopPropagation();
        toggleDropdown(trigger);
        return;
      }

      // Handle overlay click
      const overlay = e.target.closest('[data-role="sidebar-overlay"]');
      if (overlay) {
        handleSidebarToggle();
        return;
      }

      // Handle actions
      const action = e.target.closest('[data-action]');
      if (!action) return;

      const actionType = action.dataset.action;
      
      switch (actionType) {
        case 'logout':
          handleLogout();
          break;
        case 'toggle-theme':
          handleThemeToggle();
          break;
        case 'notifications':
          handleNotifications();
          break;
        case 'sidebar-toggle':
          handleSidebarToggle();
          break;
      }
      return;
    });

    // Close dropdown when clicking outside
    document.addEventListener('click', (e) => {
      const dropdown = document.querySelector('[data-menu].show');
      if (dropdown && !e.target.closest('[data-menu]')) {
        closeDropdown();
      }
    });

    // Setup ESC key handler
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      const html = document.documentElement;
      if (html.classList.contains('sidebar-open')) {
        handleSidebarToggle(); // Close sidebar on ESC
      }
    }
  });
  }

  /**
   * Toggle dropdown menu
   */
  function toggleDropdown(trigger) {
    const menu = document.querySelector('[data-menu]');
    if (!menu) return;

    const isOpen = menu.classList.contains('show');
    
    // Close all dropdowns
    document.querySelectorAll('[data-menu].show').forEach(d => {
      d.classList.remove('show');
    });

    // Open this dropdown if it was closed
    if (!isOpen) {
      menu.classList.add('show');
      // Position dropdown relative to trigger
      const rect = trigger.getBoundingClientRect();
      menu.style.position = 'fixed';
      menu.style.top = `${rect.bottom + 8}px`;
      menu.style.right = `${window.innerWidth - rect.right}px`;
    }
  }

  /**
   * Close dropdown menu
   */
  function closeDropdown() {
    document.querySelectorAll('[data-menu].show').forEach(menu => {
      menu.classList.remove('show');
    });
  }

  /**
   * Wire logout button
   */
  function wireLogout() {
    // Logout is handled via event delegation above
  }

  /**
   * Handle logout
   */
  async function handleLogout() {
    try {
      console.log('🚪 Signing out...');
      
      // Close dropdown
      closeDropdown();
      
      // Sign out from Supabase
      if (window.supabase?.auth) {
        await window.supabase.auth.signOut();
      } else if (window.SupabaseClient) {
        await window.SupabaseClient.signOut();
      }
      
      // Redirect to login
      window.location.href = '/login.html';
    } catch (error) {
      console.error('Logout failed:', error);
      // Still redirect on error
      window.location.href = '/login.html';
    }
  }

  /**
   * Wire theme toggle
   */
  function wireThemeToggle() {
    // Theme toggle is handled via event delegation above
  }

  /**
   * Handle theme toggle
   */
  function handleThemeToggle() {
    const currentTheme = localStorage.getItem('theme') || 'light';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    // Update localStorage
    localStorage.setItem('theme', newTheme);
    
    // Update HTML data-attribute
    const html = document.documentElement;
    html.setAttribute('data-theme', newTheme);
    
    // Update toggle text if it exists
    const toggleText = document.querySelector('[data-action="toggle-theme"] span');
    if (toggleText) {
      toggleText.textContent = newTheme === 'dark' ? 'Light mode' : 'Dark mode';
    }
    
    console.log(`🎨 Theme changed to: ${newTheme}`);
    
    // Close dropdown
    closeDropdown();
  }

  /**
   * Wire notifications bell
   */
  function wireNotifications() {
    // Notifications are handled via event delegation above
  }

  /**
   * Handle notifications bell click
   */
  function handleNotifications() {
    console.log('🔔 Opening notifications...');
    
    // Close dropdown
    closeDropdown();
    
    // Open notifications modal
    openNotifications();
  }

  /**
   * Open notifications modal
   */
  function openNotifications() {
    if (window.showModal) {
      window.showModal({
        title: 'Notifications',
        message: 'No notifications yet.',
        primaryText: 'Close'
      });
    } else {
      // Fallback if modal system not loaded
      alert('No notifications yet.');
    }
  }

  /**
   * Close notifications modal (for completeness)
   */
  function closeNotifications() {
    if (window.hideModal) {
      window.hideModal();
    }
  }

  /**
   * Handle sidebar toggle
   */
  function handleSidebarToggle() {
    const html = document.documentElement;
    const sidebar = document.querySelector('[data-role="sidebar"]');
    const overlay = document.querySelector('[data-role="sidebar-overlay"]');
    
    if (!sidebar || !overlay) return;
    
    const isOpen = html.classList.contains('sidebar-open');
    
    if (isOpen) {
      html.classList.remove('sidebar-open');
      // Properly hide overlay to prevent it from being stuck
      overlay.style.display = 'none';
      overlay.style.visibility = 'hidden';
      overlay.style.opacity = '0';
      overlay.style.pointerEvents = 'none';
    } else {
      html.classList.add('sidebar-open');
      overlay.style.display = 'block';
      overlay.style.visibility = 'visible';
      overlay.style.opacity = '1';
      overlay.style.pointerEvents = 'auto';
    }
  }

  // Auto-initialize when script loads
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAppShell);
  } else {
    initAppShell();
  }

  // Export functions for external use
  window.initAppShell = initAppShell;
  window.openNotifications = openNotifications;
  window.closeNotifications = closeNotifications;
}
