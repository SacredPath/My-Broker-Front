/**
 * Index Page Controller
 * Each HTML page loads only its page controller
 * All page controllers call api.js only (no inline fetch)
 */

class IndexPage {
  constructor() {
    this.init();
  }

  async init() {
    console.log('Index page initializing...');
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupPage());
    } else {
      this.setupPage();
    }
  }

  async setupPage() {
    try {
      // Setup UI components
      this.setupThemeToggle();
      this.setupAuthButton();
      this.setupHeroActions();
      this.setupNavigation();
      
      // Load initial data
      await this.loadStats();
      
      // Setup periodic updates
      this.setupPeriodicUpdates();
      
      console.log('Index page setup complete');
    } catch (error) {
      console.error('Error setting up index page:', error);
      if (window.Notify) {
        window.Notify.error('Failed to load page properly');
      }
    }
  }

  setupThemeToggle() {
    const themeToggle = document.getElementById('theme-toggle');
    if (!themeToggle) return;

    themeToggle.addEventListener('click', () => {
      const newTheme = window.UI ? window.UI.toggleTheme() : this.toggleTheme();
      console.log('Theme changed to:', newTheme);
    });
  }

  toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    console.log('Theme changed to:', newTheme);
    return newTheme;
  }

  async setupAuthButton() {
    const authButton = document.getElementById('auth-button');
    if (!authButton) return;

    authButton.addEventListener('click', async () => {
      try {
        // Check current auth status using new auth service
        const user = await window.AuthService.getCurrentUserWithProfile();
        
        if (user) {
          // User is logged in, show profile options
          await this.showProfileMenu(user);
        } else {
          // User is not logged in, redirect to login
          window.location.href = '/login.html';
        }
      } catch (error) {
        console.error('Auth check failed:', error);
        window.location.href = '/login.html';
      }
    });

    // Update button text based on auth status
    this.updateAuthButton();
  }

  async updateAuthButton() {
    const authButton = document.getElementById('auth-button');
    if (!authButton) return;

    try {
      const user = await window.AuthService.getCurrentUserWithProfile();
      if (user) {
        authButton.textContent = user.profile?.display_name || user.email?.split('@')[0] || 'Profile';
        authButton.className = 'btn btn-secondary btn-sm';
      } else {
        authButton.textContent = 'Sign In';
        authButton.className = 'btn btn-primary btn-sm';
      }
    } catch (error) {
      authButton.textContent = 'Sign In';
      authButton.className = 'btn btn-primary btn-sm';
    }
  }

  async showProfileMenu(user) {
    if (!window.UI) return;

    const modalId = window.UI.createModal({
      title: 'Profile',
      body: `
        <div class="profile-menu">
          <div class="profile-header">
            <div class="profile-avatar">
              <div class="avatar-placeholder">
                ${(user.profile?.display_name || user.email?.charAt(0) || 'U').toUpperCase()}
              </div>
            </div>
            <div class="profile-info">
              <h3>${user.profile?.display_name || 'User'}</h3>
              <p>${user.email}</p>
              <p class="profile-role">Role: ${user.profile?.role || 'user'}</p>
            </div>
          </div>
          <div class="profile-actions">
            <button class="btn btn-secondary" onclick="window.location.href='/app/home.html'" style="width: 100%;">
              📊 Dashboard
            </button>
            <button class="btn btn-secondary" onclick="window.location.href='/app/settings.html'" style="width: 100%;">
              ⚙️ Account Settings
            </button>
            <button class="btn btn-danger" id="logout-btn" style="width: 100%;">
              🚪 Sign Out
            </button>
          </div>
        </div>
      `,
      footer: `<button class="btn btn-ghost" onclick="window.UI.closeAllModals()">Close</button>`
    });

    window.UI.openModal(modalId);

    // Setup logout button
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', async () => {
        await window.AuthService.logout();
      });
    }
  }

  setupHeroActions() {
    const getStartedBtn = document.getElementById('get-started-btn');
    const learnMoreBtn = document.getElementById('learn-more-btn');
    const tradeBtn = document.getElementById('trade-btn');

    if (getStartedBtn) {
      getStartedBtn.addEventListener('click', () => {
        window.location.href = '/app/home.html';
      });
    }

    if (learnMoreBtn) {
      learnMoreBtn.addEventListener('click', () => {
        if (window.UI) {
          window.UI.createModal({
            title: 'About Broker',
            body: `
              <p>Broker is a premium trading platform designed for both beginners and experienced traders.</p>
              <h3>Key Features:</h3>
              <ul>
                <li>Real-time market data</li>
                <li>Advanced charting tools</li>
                <li>Secure wallet integration</li>
                <li>24/7 customer support</li>
                <li>Mobile-first design</li>
              </ul>
              <p>Get started today and experience the future of trading!</p>
            `,
            footer: `<button class="btn btn-primary" onclick="window.UI.closeAllModals()">Got it</button>`
          });
          window.UI.openModal(window.UI.modals[window.UI.modals.length - 1]?.id);
        }
      });
    }

    if (tradeBtn) {
      tradeBtn.addEventListener('click', () => {
        this.showComingSoonModal();
      });
    }
  }

  setupNavigation() {
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
      link.addEventListener('click', (e) => {
        // Handle trade link specifically
        if (e.target.id === 'trade-link') {
          e.preventDefault();
          this.showComingSoonModal();
          return;
        }
        
        // Remove active class from all links
        navLinks.forEach(l => l.classList.remove('active'));
        // Add active class to clicked link
        e.target.classList.add('active');
      });
    });
  }

  showComingSoonModal() {
    if (window.Notify) {
      window.Notify.info('Trading feature coming soon! We\'re working hard to bring you the best trading experience.');
    } else {
      // Fallback: create a simple modal
      const modalId = `modal-${Date.now()}`;
      const modal = document.createElement('div');
      modal.id = modalId;
      modal.className = 'modal-overlay';
      modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
      `;

      modal.innerHTML = `
        <div style="
          background: var(--surface);
          border-radius: 16px;
          padding: 32px;
          max-width: 400px;
          width: 90%;
          text-align: center;
          border: 1px solid var(--border);
        ">
          <div style="font-size: 48px; margin-bottom: 16px;">🚀</div>
          <h3 style="margin-bottom: 16px; color: var(--text);">Coming Soon!</h3>
          <p style="color: var(--text-secondary); margin-bottom: 24px; line-height: 1.5;">
            Trading feature coming soon! We're working hard to bring you the best trading experience.
          </p>
          <button class="btn btn-primary" onclick="document.getElementById('${modalId}').remove()" style="background: var(--primary); color: white; border: none; padding: 12px 24px; border-radius: 8px; cursor: pointer;">
            Got it!
          </button>
        </div>
      `;

      document.body.appendChild(modal);

      // Add click outside to close
      modal.addEventListener('click', (e) => {
        if (e.target === modal) {
          modal.remove();
        }
      });
    }
  }

  async loadStats() {
    try {
      // In a real app, this would call an Edge Function
      // For now, we'll simulate with mock data that would come from API
      const stats = await this.fetchStats();
      this.updateStatsDisplay(stats);
    } catch (error) {
      console.error('Failed to load stats:', error);
      // Show default values on error
      this.updateStatsDisplay({
        users: 12500,
        volume: 2500000,
        transactions: 45000,
        uptime: '99.9%'
      });
    }
  }

  async fetchStats() {
    // This would normally call: window.API.fetchEdge('/stats')
    // For demo purposes, returning simulated data
    return {
      users: Math.floor(Math.random() * 5000) + 10000,
      volume: Math.floor(Math.random() * 1000000) + 2000000,
      transactions: Math.floor(Math.random() * 10000) + 40000,
      uptime: '99.9%'
    };
  }

  updateStatsDisplay(stats) {
    const userStat = document.querySelector('[data-stat="users"]');
    const volumeStat = document.querySelector('[data-stat="volume"]');
    const transactionStat = document.querySelector('[data-stat="transactions"]');
    const uptimeStat = document.querySelector('[data-stat="uptime"]');

    if (userStat) {
      this.animateNumber(userStat, stats.users);
    }

    if (volumeStat) {
      this.animateMoney(volumeStat, stats.volume, 'USD');
    }

    if (transactionStat) {
      this.animateNumber(transactionStat, stats.transactions);
    }

    if (uptimeStat) {
      uptimeStat.textContent = stats.uptime;
    }
  }

  animateNumber(element, target) {
    const duration = 2000;
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
      current += increment;
      if (current >= target) {
        current = target;
        clearInterval(timer);
      }
      element.textContent = Math.floor(current).toLocaleString();
    }, 16);
  }

  animateMoney(element, target, currency) {
    if (window.Money) {
      const money = window.Money.create(target, currency);
      const formatted = window.Money.format(money);
      element.textContent = formatted;
    } else {
      element.textContent = `$${target.toLocaleString()}`;
    }
  }

  setupPeriodicUpdates() {
    // Update stats every 30 seconds
    setInterval(() => {
      this.loadStats();
    }, 30000);

    // Update auth status every 10 seconds
    setInterval(() => {
      this.updateAuthButton();
    }, 10000);
  }

  // Cleanup method
  destroy() {
    console.log('Index page cleanup');
    // Remove any intervals, event listeners, etc.
  }
}

// Initialize page controller
window.indexPage = new IndexPage();

// Export for potential testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = IndexPage;
}
