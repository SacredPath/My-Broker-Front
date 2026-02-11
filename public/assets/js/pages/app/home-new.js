/**
 * Home Page Controller - REST API Only Version
 * Handles dashboard display, user stats, and recent activity
 * All theme handling goes through AppShell - no duplicate theme systems
 */

class HomePage {
  constructor() {
    this.currentUser = null;
    this.dashboardData = null;
    this.recentActivity = null;
    
    // Get API client
    this.api = window.API || null;
    
    this.init();
  }

  init() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupPage());
    } else {
      this.setupPage();
    }
  }

  async setupPage() {
    try {
      // Initialize app shell FIRST - this handles all sidebar and theme functionality
      if (window.AppShell) {
        window.AppShell.initShell();
      }
      
      // Setup page content
      await this.updateUserDisplay();
      await this.loadDashboardData();
      await this.loadRecentActivity();
      
      console.log('Home page setup complete');
    } catch (error) {
      console.error('HomePage: Failed to setup page:', error);
    }
  }

  async updateUserDisplay() {
    try {
      if (!this.api) {
        throw new Error('API client not available');
      }

      // Get current user ID using REST API
      const { data: user } = await this.api.getUsers();
      if (!user || user.length === 0) {
        throw new Error('No users found');
      }

      const currentUser = user[0];
      this.currentUser = currentUser;
      
      // Update user display
      const userDisplay = document.getElementById('user-display');
      if (userDisplay) {
        userDisplay.textContent = `${currentUser.first_name || 'User'} ${currentUser.last_name || ''}`;
      }
      
      console.log('HomePage: User display updated');
    } catch (error) {
      console.error('HomePage: Failed to update user display:', error);
    }
  }

  async loadDashboardData() {
    try {
      if (!this.api) {
        throw new Error('API client not available');
      }

      // Get current user ID using REST API
      const { data: user } = await this.api.getUsers();
      if (!user || user.length === 0) {
        throw new Error('No users found');
      }

      const currentUser = user[0];
      this.currentUser = currentUser;
      
      // Get portfolio snapshot using REST API
      const portfolioData = await this.api.getPortfolioSnapshot(currentUser.id);
      this.dashboardData = this.api.mapPortfolioSnapshot(portfolioData);
      
      console.log('HomePage: Loading real dashboard data...');
    } catch (error) {
      console.error('HomePage: Failed to load dashboard data:', error);
    }
  }

  async loadRecentActivity() {
    try {
      if (!this.api) {
        throw new Error('API client not available');
      }

      // Get current user ID using REST API
      const { data: user } = await this.api.getUsers();
      if (!user || user.length === 0) {
        throw new Error('No users found');
      }

      const currentUser = user[0];
      this.currentUser = currentUser;
      
      // Get recent activity using REST API
      const activityData = await this.api.fetchPositionsList(currentUser.id);
      this.recentActivity = activityData;
      
      console.log('HomePage: Loading recent activity from database...');
    } catch (error) {
      console.error('HomePage: Failed to load recent activity:', error);
    }
  }
}

// Initialize page controller
window.homePage = new HomePage();
