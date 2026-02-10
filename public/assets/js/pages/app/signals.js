/**
 * Signals Page Controller
 * Handles signals marketplace listing, filtering, and purchasing
 */

class SignalsPage {
  constructor() {
    this.currentUser = null;
    this.signals = [];
    this.userAccess = [];
    this.userPositions = [];
    this.filters = {
      category: '',
      risk: '',
      type: '',
      sort: 'newest'
    };
    this.selectedSignal = null;
    
    // Get API client
    this.api = window.API || null;

    if (!this.api) {
      console.warn("SignalsPage: API client not found on load. Retrying in 500ms...");
      setTimeout(() => this.retryInit(), 500);
    } else {
      this.init();
    }
  }

  retryInit() {
    this.api = window.API || null;
    if (this.api) {
      this.init();
    } else {
      // Retry again if API client still not available
      setTimeout(() => this.retryInit(), 500);
    }
  }

  async init() {
    console.log('Signals page initializing...');
    
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupPage());
    } else {
      this.setupPage();
    }
  }

  async setupPage() {
    try {
      
      // Load data
      await this.loadUserData();
      await this.loadUserPositions();
      await this.loadSignals();
      await this.loadUserAccess();
      
      // Setup UI
      this.setupFilters();
      this.renderSignals();
      this.checkPurchaseBlock();
      
      console.log('Signals page setup complete');
    } catch (error) {
      console.error('Error setting up signals page:', error);
      if (window.Notify) {
        window.Notify.error('Failed to load signals');
      }
    }
  }

  async loadUserData() {
    try {
      console.log('Loading user data via REST API...');
      
      // Get current user ID
      const userId = await this.api.getCurrentUserId();
      if (!userId) {
        throw new Error('User not authenticated');
      }

      // For now, use mock data since we don't have a user profile API endpoint yet
      // TODO: Replace with actual REST API call when available
      // const data = await this.api.getUserProfile(userId);
      
      this.currentUser = this.getMockUser();
      console.log('User data loaded:', this.currentUser);
    } catch (error) {
      console.error('Failed to load user data:', error);
      this.currentUser = this.getMockUser();
    }
  }

  async loadUserPositions() {
    try {
      console.log('Loading user positions via REST API...');
      
      // For now, use empty array since we don't have a positions API endpoint yet
      // TODO: Replace with actual REST API call when available
      // const data = await this.api.getUserPositions(userId);
      
      this.userPositions = [];
      console.log('User positions loaded:', this.userPositions.length, 'positions');
    } catch (error) {
      console.error('Failed to load user positions:', error);
      this.userPositions = [];
    }
  }

  async loadSignals() {
    try {
      console.log('Loading signals from database...');
      
      // Load signals from REST API
      const response = await fetch('http://localhost:3001/api/signals', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${await this.getAuthToken()}`
        }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      
      if (data.error) {
        console.error('Database error loading signals:', data.error);
        this.signals = [];
        return;
      }
      
      this.signals = data.signals || [];
      console.log('Signals loaded from database:', this.signals.length, 'signals');
      this.setupFilterOptions();
    } catch (error) {
      console.error('Failed to load signals:', error);
      this.signals = [];
    }
  }

  async loadUserAccess() {
    try {
      console.log('Loading user signal access via REST API...');
      
      // Load user signal access from REST API
      const response = await fetch('http://localhost:3001/api/user-access', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${await this.getAuthToken()}`
        }
      });
      
      if (!response.ok) {
        if (response.status === 401) {
          console.log('User not authenticated, skipping signal access check');
          this.userAccess = [];
          return;
        }
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      
      if (data.error) {
        console.error('Database error loading user access:', data.error);
        this.userAccess = [];
        return;
      }
      
      this.userAccess = data.access || [];
      console.log('User signal access loaded:', this.userAccess.length, 'access records');
    } catch (error) {
      console.error('Failed to load user signal access:', error);
      this.userAccess = [];
    }
  }

  async getAuthToken() {
    try {
      // Get auth token from Supabase client
      if (window.API && window.API.supabase) {
        const { data: { session } } = await window.API.supabase.auth.getSession();
        return session?.access_token || null;
      }
      return null;
    } catch (error) {
      console.error('Error getting auth token:', error);
      return null;
    }
  }

  getMockUser() {
    return {
      id: 'user_123',
      email: 'user@example.com',
      profile: {
        display_name: 'John Doe',
        kyc_status: 'approved',
        email_verified: true
      }
    };
  }

  getMockSignals() {
    return [
      {
        id: 'signal_1',
        title: 'Gold Bullish Breakout',
        description: 'Technical analysis indicating strong upward momentum for gold based on key resistance break',
        category: 'Commodities',
        risk_level: 'Medium',
        type: 'one-time',
        price: 50.000000,
        access_duration: 30,
        purchase_count: 127,
        created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
        expires_at: new Date(Date.now() + 28 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 'signal_2',
        title: 'EUR/USD Reversal Pattern',
        description: 'Identified double bottom formation suggesting bullish reversal in EUR/USD pair',
        category: 'Forex',
        risk_level: 'Low',
        type: 'subscription',
        price: 100.000000,
        access_duration: 30,
        purchase_count: 89,
        created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
        expires_at: new Date(Date.now() + 25 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 'signal_3',
        title: 'Tech Sector Momentum',
        description: 'Comprehensive analysis of major tech stocks showing strong buying opportunities',
        category: 'Stocks',
        risk_level: 'High',
        type: 'one-time',
        price: 75.000000,
        access_duration: 7,
        purchase_count: 203,
        created_at: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
        expires_at: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000).toISOString()
      }
    ];
  }

  setupFilterOptions() {
    const categoryFilter = document.getElementById('category-filter');
    if (!categoryFilter) return;

    // Get unique categories
    const categories = [...new Set(this.signals.map(signal => signal.category))];
    
    categories.forEach(category => {
      const option = document.createElement('option');
      option.value = category;
      option.textContent = category;
      categoryFilter.appendChild(option);
    });
  }

  setupFilters() {
    // Filter event listeners are set up in HTML with onchange
  }

  applyFilters() {
    // Update filter values
    this.filters.category = document.getElementById('category-filter').value;
    this.filters.risk = document.getElementById('risk-filter').value;
    this.filters.type = document.getElementById('type-filter').value;
    this.filters.sort = document.getElementById('sort-filter').value;

    // Re-render signals with filters
    this.renderSignals();
  }

  getFilteredSignals() {
    let filtered = [...this.signals];

    // Apply category filter
    if (this.filters.category) {
      filtered = filtered.filter(signal => signal.category === this.filters.category);
    }

    // Apply risk filter
    if (this.filters.risk) {
      filtered = filtered.filter(signal => signal.risk_level === this.filters.risk);
    }

    // Apply type filter
    if (this.filters.type) {
      filtered = filtered.filter(signal => signal.type === this.filters.type);
    }

    // Apply sorting
    switch (this.filters.sort) {
      case 'price-low':
        filtered.sort((a, b) => a.price - b.price);
        break;
      case 'price-high':
        filtered.sort((a, b) => b.price - a.price);
        break;
      case 'popular':
        filtered.sort((a, b) => b.purchase_count - a.purchase_count);
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        break;
    }

    return filtered;
  }

  checkPurchaseBlock() {
    const blockedBanner = document.getElementById('blocked-banner');
    if (!blockedBanner) return;

    // Check if user has any active unmatured positions
    const hasActivePositions = this.userPositions.some(position => 
      position.status === 'active' && new Date(position.matures_at) > new Date()
    );

    if (hasActivePositions) {
      blockedBanner.style.display = 'flex';
    } else {
      blockedBanner.style.display = 'none';
    }
  }

  renderSignals() {
    const signalsGrid = document.getElementById('signals-grid');
    if (!signalsGrid) return;

    const filteredSignals = this.getFilteredSignals();
    
    if (filteredSignals.length === 0) {
      signalsGrid.innerHTML = `
        <div class="empty-state" style="grid-column: 1 / -1;">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"></path>
            <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"></path>
          </svg>
          <h3>No signals found</h3>
          <p>Try adjusting your filters or check back later for new signals.</p>
        </div>
      `;
      return;
    }

    signalsGrid.innerHTML = filteredSignals.map(signal => {
      const hasAccess = this.userAccess.some(access => 
        access.signal_id === signal.id && 
        new Date(access.access_expires_at) > new Date()
      );

      const hasActivePositions = this.userPositions.some(position => 
        position.status === 'active' && new Date(position.matures_at) > new Date()
      );

      return `
        <div class="signal-card ${hasAccess ? 'purchased' : ''}" data-signal-id="${signal.id}">
          <div class="signal-header">
            <h3 class="signal-title">${signal.title}</h3>
                <p class="signal-description">${signal.description}</p>
            </div>
            
            <div class="signal-meta">
                <span class="signal-tag tag-category">${signal.category}</span>
                <span class="signal-tag tag-risk ${signal.risk_level}">${signal.risk_level} risk</span>
                <span class="signal-tag">${signal.type === 'subscription' ? 'Subscription' : 'One-time'}</span>
            </div>
            
            <div class="signal-details">
                <div class="detail-item">
                    <span class="detail-label">Price</span>
                    <span class="detail-value price">₮${this.formatMoney(signal.price, 6)}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Duration</span>
                    <span class="detail-value duration">${this.getDurationText(signal.access_duration)}</span>
                </div>
            </div>
            
            <div class="signal-actions">
                <button class="btn btn-small btn-view" onclick="window.signalsPage.viewSignalDetail('${signal.string_id}')">
                    View Details
                </button>
                ${hasAccess ? `
                    <button class="btn btn-small btn-download" onclick="window.signalsPage.downloadSignal('${signal.id}')">
                        Download PDF
                    </button>
                ` : `
                    <button class="btn btn-small btn-purchase" 
                            onclick="window.signalsPage.openPurchaseModal('${signal.id}')"
                            ${hasActivePositions ? 'disabled title="Purchase blocked while you have active positions"' : ''}>
                        Purchase
                    </button>
                `}
            </div>
        </div>
      `;
    }).join('');
  }

  getDurationText(duration) {
    switch (duration) {
      case 7: return '7 days';
      case 30: return '30 days';
      case 90: return '90 days';
      default: return `${duration} days`;
    }
  }

  async viewSignalDetail(signalId) {
    const signal = this.signals.find(s => s.string_id === signalId);
    if (!signal) return;

    // Navigate to signal detail page using string_id
    window.location.href = `/app/signal_detail.html?id=${signalId}`;
  }

  async openPurchaseModal(signalId) {
    const signal = this.signals.find(s => s.id === signalId);
    if (!signal) return;

    // Check if user has active positions
    const hasActivePositions = this.userPositions.some(position => 
      position.status === 'active' && new Date(position.matures_at) > new Date()
    );

    if (hasActivePositions) {
      window.Notify.error('Signal purchases are blocked while you have active positions');
      return;
    }

    this.selectedSignal = signal;
    
    const purchaseSummary = document.getElementById('purchase-summary');
    const subscriptionInfo = document.getElementById('subscription-info');
    const modal = document.getElementById('purchase-modal');
    
    // Calculate total cost
    const totalCost = signal.type === 'subscription' 
      ? signal.price 
      : signal.price;

    purchaseSummary.innerHTML = `
      <div class="purchase-row">
        <span class="purchase-label">Signal:</span>
        <span class="purchase-value">${signal.title}</span>
      </div>
      <div class="purchase-row">
        <span class="purchase-label">Type:</span>
        <span class="purchase-value">${signal.type === 'subscription' ? 'Subscription' : 'One-time Purchase'}</span>
      </div>
      <div class="purchase-row">
        <span class="purchase-label">Access Duration:</span>
        <span class="purchase-value">${this.getDurationText(signal.access_duration)}</span>
      </div>
      <div class="purchase-row">
        <span class="purchase-label">Risk Level:</span>
        <span class="purchase-value">${signal.risk_level}</span>
      </div>
      <div class="purchase-row">
        <span class="purchase-label">Category:</span>
        <span class="purchase-value">${signal.category}</span>
      </div>
      ${signal.type === 'subscription' ? `
        <div class="purchase-row">
          <span class="purchase-label">Billing Cycle:</span>
          <span class="purchase-value">Every ${this.getDurationText(signal.access_duration)}</span>
        </div>
      ` : ''}
      <div class="purchase-row highlight">
        <span class="purchase-label">Total Cost:</span>
        <span class="purchase-value highlight">₮${this.formatMoney(totalCost, 6)}</span>
      </div>
    `;

    // Show subscription info if applicable
    if (signal.type === 'subscription') {
      subscriptionInfo.style.display = 'block';
    } else {
      subscriptionInfo.style.display = 'none';
    }

    modal.style.display = 'flex';
  }

  closePurchaseModal() {
    const modal = document.getElementById('purchase-modal');
    modal.style.display = 'none';
    this.selectedSignal = null;
  }

  async confirmPurchase() {
    if (!this.selectedSignal) return;

    try {
      this.setButtonLoading('confirm-purchase-btn', true);

      // Create signal purchase via REST API
      const response = await fetch(`http://localhost:3001/api/signals/${this.selectedSignal.id}/purchase`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${await this.getAuthToken()}`
        },
        body: JSON.stringify({
          signal_id: this.selectedSignal.id,
          price: this.selectedSignal.price || this.selectedSignal.price_usdt,
          currency: 'USDT'
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || `HTTP ${response.status}: ${response.statusText}`);
      }

      const purchaseData = await response.json();

      // Get USDT deposit address for payment
      let depositAddress = null;
      try {
        const addressResponse = await fetch('http://localhost:3001/api/deposit-address', {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${await this.getAuthToken()}`
          }
        });

        if (addressResponse.ok) {
          const addressData = await addressResponse.json();
          depositAddress = addressData.address;
        }
      } catch (error) {
        console.warn('Could not fetch deposit address:', error);
      }

      // Show deposit instructions
      this.showDepositInstructions(depositAddress, this.selectedSignal.price, purchaseData.purchase_id);

    } catch (error) {
      console.error('Purchase failed:', error);
      window.Notify.error(error.message || 'Failed to initiate purchase');
    } finally {
      this.setButtonLoading('confirm-purchase-btn', false);
    }
  }

  showDepositInstructions(depositAddress, amount, purchaseId) {
    // Close purchase modal
    this.closePurchaseModal();

    // Create deposit instructions modal
    const modalHtml = `
      <div class="modal-overlay" id="deposit-instructions-modal" style="display: flex;">
        <div class="modal deposit-modal-content">
          <div class="modal-header">
            <h3>USDT Deposit Required</h3>
            <button class="modal-close" onclick="window.signalsPage.closeDepositInstructions()">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
          <div class="modal-body">
            <div class="deposit-summary">
              <div class="deposit-row">
                <span class="deposit-label">Signal:</span>
                <span class="deposit-value">${this.selectedSignal.title}</span>
              </div>
              <div class="deposit-row">
                <span class="deposit-label">Amount to Deposit:</span>
                <span class="deposit-value highlight">₮${this.formatMoney(amount, 6)}</span>
              </div>
              <div class="deposit-row">
                <span class="deposit-label">Currency:</span>
                <span class="deposit-value">USDT</span>
              </div>
              <div class="deposit-row">
                <span class="deposit-label">Purchase ID:</span>
                <span class="deposit-value">${purchaseId}</span>
              </div>
            </div>
            
            ${depositAddress ? `
              <div class="deposit-address-section">
                <h4>Deposit Address</h4>
                <div class="address-container">
                  <input type="text" value="${depositAddress}" readonly id="deposit-address-input" />
                  <button class="btn btn-small" onclick="window.signalsPage.copyAddress()">Copy</button>
                </div>
                <p class="address-warning">Send exactly ₮${this.formatMoney(amount, 6)} to this address. Your access will be activated automatically after confirmation.</p>
              </div>
            ` : `
              <div class="no-address-section">
                <div class="warning-icon">
                  <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="12" y1="8" x2="12" y2="12"></line>
                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                  </svg>
                </div>
                <h4>Deposit Address Not Available</h4>
                <p>The USDT deposit address is currently not set by the administrator. Please contact support or try again later.</p>
                <div class="deposit-actions">
                  <button class="btn btn-secondary" onclick="window.signalsPage.closeDepositInstructions()">Close</button>
                  <button class="btn btn-primary" onclick="window.signalsPage.checkForAddress()">Check Again</button>
                </div>
              </div>
            `}
          </div>
        </div>
      </div>
    `;

    // Add modal to page
    const modalContainer = document.createElement('div');
    modalContainer.innerHTML = modalHtml;
    document.body.appendChild(modalContainer.firstElementChild);
  }

  closeDepositInstructions() {
    const modal = document.getElementById('deposit-instructions-modal');
    if (modal) {
      modal.remove();
    }
  }

  copyAddress() {
    const input = document.getElementById('deposit-address-input');
    if (input) {
      input.select();
      document.execCommand('copy');
      window.Notify.success('Address copied to clipboard!');
    }
  }

  async checkForAddress() {
    // Refresh and check for address again
    const { data: addressData, error: addressError } = await window.API.serviceClient
      .from('deposit_addresses')
      .select('address')
      .eq('currency', 'USDT')
      .eq('is_active', true)
      .maybeSingle();

    if (!addressError && addressData?.address) {
      window.Notify.success('Deposit address is now available!');
      this.showDepositInstructions(addressData.address, this.selectedSignal.price, this.selectedSignal.id);
    } else {
      window.Notify.error('Deposit address still not available');
    }
  }

  calculateExpiryDate(accessDuration) {
    const now = new Date();
    let expiryDate = new Date(now);

    // Parse access duration (e.g., "30_days", "90_days", "365_days")
    const days = parseInt(accessDuration.split('_')[0]) || 30;
    expiryDate.setDate(expiryDate.getDate() + days);

    return expiryDate.toISOString();
  }

  async downloadSignal(signalId) {
    try {
      // Check if user has access
      const access = this.userAccess.find(a => 
        a.signal_id === signalId && 
        new Date(a.access_expires_at) > new Date()
      );

      if (!access) {
        window.Notify.error('You do not have access to this signal');
        return;
      }

      // Get secure download URL using REST API
      const { data, error } = await window.API.serviceClient
        .rpc('signal_download_url_rest', {
          p_signal_id: signalId,
          p_user_id: window.API.getCurrentUserId(),
          p_access_id: access.id
        });

      if (error) {
        throw error;
      }

      // Create download link
      const link = document.createElement('a');
      link.href = data.download_url;
      link.download = `signal_${signalId}.pdf`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      window.Notify.success('Signal PDF downloaded successfully!');

    } catch (error) {
      console.error('Download failed:', error);
      window.Notify.error(error.message || 'Failed to download signal');
    }
  }

  setButtonLoading(buttonId, loading) {
    const button = document.getElementById(buttonId);
    if (!button) return;

    if (loading) {
      button.disabled = true;
      button.innerHTML = `
        <div class="loading-spinner" style="display: inline-block; margin-right: 8px;"></div>
        Processing...
      `;
    } else {
      button.disabled = false;
      button.textContent = 'Proceed to Payment';
    }
  }

  formatMoney(amount, precision = 2) {
    if (typeof amount === 'string') {
      amount = parseFloat(amount);
    }
    return amount.toLocaleString('en-US', {
      minimumFractionDigits: precision,
      maximumFractionDigits: precision
    });
  }

  // Cleanup method
  destroy() {
    console.log('Signals page cleanup');
  }
}

// Initialize page controller
window.signalsPage = new SignalsPage();

// Export for potential testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SignalsPage;
}
