/**
 * Profile Page Controller
 * Handles profile display and management
 */

// Import shared app initializer
import '/src/js/_shared/app_init.js';

class ProfilePage {
  constructor() {
    this.currentUser = null;
    this.userProfile = null;
    this.userPositions = [];
    this.init();
  }

  async init() {
    console.log('Profile page initializing...');
    
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupPage());
    } else {
      this.setupPage();
    }
  }

  async setupPage() {
    try {
      // Initialize app shell (sidebar, navigation, etc.)
      if (window.AppShell) {
        window.AppShell.initShell();
      }
      
      // Load user data
      await this.loadUserData();
      
      // Display profile information
      this.displayProfile();
      
      console.log('Profile page setup complete');
    } catch (error) {
      console.error('Error setting up profile page:', error);
      this.showError('Failed to load profile information');
    }
  }

  async loadUserData() {
    try {
      // Get current user with profile
      this.currentUser = await window.AuthService.getCurrentUserWithProfile();
      
      if (!this.currentUser) {
        throw new Error('User not authenticated');
      }

      this.userProfile = this.currentUser.profile;
      
      // Load user positions for stats
      await this.loadUserPositions();
    } catch (error) {
      console.error('Failed to load user data:', error);
      throw error;
    }
  }

  async loadUserPositions() {
    try {
      const { data, error } = await window.API.fetchEdge('positions_list', {
        method: 'GET'
      });

      if (error) {
        console.warn('Failed to load user positions:', error);
        this.userPositions = [];
      } else {
        this.userPositions = data.positions || [];
      }
    } catch (error) {
      console.error('Failed to load user positions:', error);
      this.userPositions = [];
    }
  }

  displayProfile() {
    // Hide loading state
    const loadingState = document.getElementById('loading-state');
    const errorState = document.getElementById('error-state');
    const profileContent = document.getElementById('profile-content');
    
    if (loadingState) loadingState.style.display = 'none';
    if (errorState) errorState.style.display = 'none';
    if (profileContent) profileContent.style.display = 'block';

    // Display user information
    this.displayPersonalInfo();
    this.displayAccountStats();
    this.displayAvatar();
  }

  displayPersonalInfo() {
    if (!this.userProfile) return;

    // Name
    const nameElement = document.getElementById('profile-name');
    if (nameElement) {
      const firstName = this.userProfile.first_name || '';
      const lastName = this.userProfile.last_name || '';
      const displayName = this.userProfile.display_name || `${firstName} ${lastName}`.trim() || 'User';
      nameElement.textContent = displayName;
    }

    // Email
    const emailElement = document.getElementById('profile-email');
    if (emailElement) {
      emailElement.textContent = this.currentUser.email || 'Not available';
    }

    // Phone
    const phoneElement = document.getElementById('profile-phone');
    if (phoneElement) {
      phoneElement.textContent = this.userProfile.phone || 'Not provided';
    }

    // Country
    const countryElement = document.getElementById('profile-country');
    if (countryElement) {
      countryElement.textContent = this.userProfile.country || 'Not provided';
    }

    // Account Status
    const statusElement = document.getElementById('profile-status');
    if (statusElement) {
      const emailVerified = this.userProfile.email_verified ? 'Verified' : 'Not Verified';
      const kycStatus = this.userProfile.kyc_status || 'not_submitted';
      statusElement.textContent = `Email: ${emailVerified} | KYC: ${this.formatKycStatus(kycStatus)}`;
    }

    // Member Since
    const createdElement = document.getElementById('profile-created');
    if (createdElement) {
      const createdDate = this.userProfile.created_at || this.currentUser.created_at;
      if (createdDate) {
        createdElement.textContent = new Date(createdDate).toLocaleDateString();
      } else {
        createdElement.textContent = 'Unknown';
      }
    }
  }

  displayAvatar() {
    const avatarElement = document.getElementById('avatar-initials');
    if (!avatarElement) return;

    const firstName = this.userProfile?.first_name || '';
    const lastName = this.userProfile?.last_name || '';
    const displayName = this.userProfile?.display_name || `${firstName} ${lastName}`.trim() || '';
    
    if (displayName) {
      // Get initials
      const names = displayName.trim().split(' ');
      const initials = names.map(name => name.charAt(0).toUpperCase()).join('').substring(0, 2);
      avatarElement.textContent = initials || 'U';
    } else {
      // Use email initial if no name
      const email = this.currentUser?.email || '';
      avatarElement.textContent = email.charAt(0).toUpperCase() || 'U';
    }
  }

  displayAccountStats() {
    // Calculate total equity
    const totalEquity = this.calculateTotalEquity();
    const equityElement = document.getElementById('total-equity');
    if (equityElement) {
      equityElement.textContent = this.formatMoney(totalEquity);
    }

    // Active positions
    const positionsElement = document.getElementById('active-positions');
    if (positionsElement) {
      const activePositions = this.userPositions.filter(pos => 
        pos.status === 'active' || pos.status === 'open'
      ).length;
      positionsElement.textContent = activePositions;
    }

    // Current strategy
    const strategyElement = document.getElementById('current-strategy');
    if (strategyElement) {
      // This would need to be implemented based on your strategy/tier logic
      const currentStrategy = this.getCurrentStrategy();
      strategyElement.textContent = currentStrategy || 'None';
    }

    // KYC Status
    const kycElement = document.getElementById('kyc-status');
    if (kycElement) {
      const kycStatus = this.userProfile?.kyc_status || 'not_submitted';
      kycElement.textContent = this.formatKycStatus(kycStatus);
    }
  }

  calculateTotalEquity() {
    // Calculate total equity from user positions (USD only)
    return this.userPositions
      .filter(pos => pos.currency === 'USD')
      .reduce((total, pos) => total + (pos.amount || 0), 0);
  }

  getCurrentStrategy() {
    // This would need to be implemented based on your strategy/tier logic
    // For now, return a placeholder
    return 'None';
  }

  formatKycStatus(status) {
    const statusMap = {
      'not_submitted': 'Not Submitted',
      'submitted': 'Submitted',
      'pending': 'Pending Review',
      'approved': 'Approved',
      'rejected': 'Rejected'
    };
    return statusMap[status] || status;
  }

  formatMoney(amount) {
    if (typeof amount !== 'number') {
      amount = parseFloat(amount) || 0;
    }
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount);
  }

  showError(message) {
    const loadingState = document.getElementById('loading-state');
    const errorState = document.getElementById('error-state');
    const profileContent = document.getElementById('profile-content');
    
    if (loadingState) loadingState.style.display = 'none';
    if (profileContent) profileContent.style.display = 'none';
    if (errorState) {
      errorState.style.display = 'block';
      const errorMessage = errorState.querySelector('.error-message');
      if (errorMessage) {
        errorMessage.textContent = message;
      }
    }
  }
}

// Initialize profile page when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.profilePage = new ProfilePage();
});

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ProfilePage;
}
