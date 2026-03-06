/**
 * Professional Deposits Page Controller - Redesigned Version
 * Clean, modern design without childish elements
 * Enhanced UX with professional styling
 */

class DepositsPage {
  constructor() {
    this.selectedMethod = null;
    this.currentUser = null;
    this.depositSettings = null;
    this.currentOrder = null;
    this.timerInterval = null;
    
    // Get API client
    this.api = window.API || null;

    if (!this.api) {
      console.warn("DepositsPage: API client not found on load. Retrying in 500ms...");
      setTimeout(() => this.retryInit(), 500);
    } else {
      // Add small delay to ensure API is fully initialized
      setTimeout(() => this.init(), 100);
    }
  }

  retryInit() {
    this.api = window.API || null;
    if (this.api) {
      this.init();
    } else {
      setTimeout(() => this.retryInit(), 500);
    }
  }

  async init() {
    console.log('Deposits page initializing...');
    
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
      await this.loadDepositSettings();
      
      // Check for upgrade context
      this.setupURLParameters();
      
      // Setup page
      this.renderDepositMethods();
      this.setupForms();
    } catch (error) {
      console.error('Deposits page setup failed:', error);
      if (window.Notify) {
        window.Notify.error('Failed to load deposit page');
      }
    }
  }

  // Professional color scheme
  getMethodColors() {
    return {
      'USDT TRC20': { primary: '#2563EB', secondary: '#1D4ED8', accent: '#4A90E2' },
      'USDT ERC20': { primary: '#3B82F6', secondary: '#1D4ED8', accent: '#2E7D32' },
      'BTC': { primary: '#F7931A', secondary: '#7C2D12', accent: '#F59E0B' },
      'ETH': { primary: '#627EEA', secondary: '#1A6F3A', accent: '#34D399' },
      'Bank Transfer': { primary: '#2E7D32', secondary: '#1A5F3A', accent: '#10B981' },
      'PayPal': { primary: '#0070BA', secondary: '#004085', accent: '#0052CC' }
    };
  }

  async loadUserData() {
    try {
      const user = await window.AuthService.getCurrentUserWithProfile();
      if (user) {
        this.currentUser = user;
        console.log('User data loaded for deposits page');
      }
    } catch (error) {
      console.error('Failed to load user data:', error);
    }
  }

  async loadDepositSettings() {
    try {
      const response = await this.api.getDepositMethods();
      if (response.success) {
        this.depositSettings = response.data;
        console.log('Deposit settings loaded:', response.data);
      } else {
        console.error('Failed to load deposit settings:', response.error);
      }
    } catch (error) {
      console.error('Error loading deposit settings:', error);
    }
  }

  setupURLParameters() {
    const urlParams = new URLSearchParams(window.location.search);
    const amount = urlParams.get('amount');
    const currency = urlParams.get('currency');
    const target = urlParams.get('target');
    const tierId = urlParams.get('tier_id');

    if (amount && currency === 'USDT' && target === 'tier_upgrade' && tierId) {
      this.prefillForTierUpgrade(amount, tierId);
    }
  }

  prefillForTierUpgrade(amount, tierId) {
    this.tierUpgradeContext = {
      target: 'tier_upgrade',
      tier_id: parseInt(tierId),
      amount: parseFloat(amount)
    };
    
    console.log('Tier upgrade context set:', this.tierUpgradeContext);
  }

  renderDepositMethods() {
    const container = document.getElementById('deposit-methods');
    if (!container || !this.depositSettings?.methods) return;

    const activeMethods = this.depositSettings.methods.filter(method => method.is_active);
    
    container.innerHTML = `
      <div class="deposits-header">
        <h1>Deposit Methods</h1>
        <p class="deposits-subtitle">Choose your preferred deposit method to fund your account</p>
      </div>
      
      <div class="methods-grid">
        ${activeMethods.map(method => this.renderMethodCard(method)).join('')}
      </div>
    `;
  }

  renderMethodCard(method) {
    const colors = this.getMethodColors()[method.method_name] || this.getMethodColors()[method.method_type];
    const icon = this.getMethodIcon(method.method_type);
    
    return `
      <div class="method-card" data-method-id="${method.id}" onclick="depositsPage.selectMethod('${method.id}')">
        <div class="method-header">
          <div class="method-icon" style="background: ${colors.primary}; color: white;">
            ${icon}
          </div>
          <div class="method-info">
            <h3>${method.method_name}</h3>
            <p class="method-type">${this.getMethodTypeLabel(method.method_type)}</p>
            ${method.processing_time_hours ? `<p class="processing-time">Processing time: ${method.processing_time_hours} hours</p>` : ''}
          </div>
        </div>
        </div>
      </div>
    `;
  }

  getMethodIcon(methodType) {
    const icons = {
      'crypto': '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><path d="M12 6v6l4 2"></path></svg>',
      'ach': '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="7" y1="21" x2="17" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>',
      'paypal': '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M7 16V4a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v8"></path><path d="M12 14H7a2 2 0 0 0-2 2h10a2 2 0 0 0 2 2v-4a2 2 0 0 0-2 2h-3"></path></svg>'
    };
    return icons[methodType] || icons['crypto'];
  }

  getMethodTypeLabel(methodType) {
    const labels = {
      'crypto': 'Cryptocurrency',
      'ach': 'Bank Transfer',
      'paypal': 'PayPal Payment'
    };
    return labels[methodType] || 'Payment Method';
  }

  selectMethod(methodId) {
    this.selectedMethod = this.depositSettings.methods.find(m => m.id === methodId);
    if (this.selectedMethod) {
      this.renderDepositForm();
    }
  }

  renderDepositForm() {
    const container = document.getElementById('deposit-form');
    if (!container || !this.selectedMethod) return;

    const colors = this.getMethodColors()[this.selectedMethod.method_name] || this.getMethodColors()[this.selectedMethod.method_type];
    
    container.innerHTML = `
      <div class="deposit-form-container">
        <div class="form-header">
          <h2>${this.selectedMethod.method_name} Deposit</h2>
          <p class="form-description">Enter the amount you wish to deposit</p>
        </div>
        
        <div class="form-content">
          ${this.renderAmountInput()}
          ${this.renderPaymentDetails()}
          ${this.renderActionButtons()}
        </div>
      </div>
    `;
    
    this.setupFormValidation();
  }

  renderAmountInput() {
    const isUpgrade = this.tierUpgradeContext?.target === 'tier_upgrade';
    const method = this.selectedMethod;
    
    if (isUpgrade) {
      return `
        <div class="upgrade-section">
          <div class="upgrade-info">
            <h3>Upgrade to Tier ${this.tierUpgradeContext.tier_id}</h3>
            <p>Required amount: <strong>${this.formatMoney(this.tierUpgradeContext.amount, method.currency === 'USDT' ? 6 : method.currency === 'BTC' ? 8 : 2)}</strong></p>
            <p>After deposit, your account will be automatically upgraded.</p>
          </div>
        </div>
      `;
    }
    
    return `
      <div class="amount-input-section">
        <label for="deposit-amount">Deposit Amount (${method.currency})</label>
        <div class="input-wrapper">
          <span class="currency-symbol">${this.getCurrencySymbol(method.currency)}</span>
          <input type="number" 
                 id="deposit-amount" 
                 min="${method.min_amount || (method.currency === 'BTC' ? 100 : 1)}" 
                 max="${method.max_amount || (method.currency === 'BTC' ? 1000000 : 999999)}" 
                 step="0.01" 
                 value="${this.tierUpgradeContext?.amount || ''}"
                 ${isUpgrade ? 'readonly' : ''}
                 placeholder="0.00">
        </div>
      </div>
      <div class="amount-limits">
        <span>Minimum: ${this.getCurrencySymbol(method.currency)}${this.formatMoney(method.min_amount || (method.currency === 'BTC' ? 100 : 1), method.currency === 'USDT' ? 6 : method.currency === 'BTC' ? 8 : 2)}</span>
        ${method.max_amount ? `<span>Maximum: ${this.getCurrencySymbol(method.currency)}${this.formatMoney(method.max_amount, method.currency === 'USDT' ? 6 : method.currency === 'BTC' ? 8 : 2)}</span>` : ''}
      </div>
    `;
  }

  getCurrencySymbol(currency) {
    const symbols = {
      'USDT': '₮',
      'BTC': '₿',
      'ETH': 'Ξ',
      'USD': '$'
    };
    return symbols[currency] || '$';
  }

  renderPaymentDetails() {
    const method = this.selectedMethod;
    
    if (method.method_type === 'crypto') {
      return `
        <div class="payment-details">
          <h4>Payment Information</h4>
          <div class="detail-row">
            <label>Network:</label>
            <div class="detail-value">${method.network || 'N/A'}</div>
          </div>
          <div class="detail-row">
            <label>Wallet Address:</label>
            <div class="detail-value address-value">
              <code>${method.address || 'N/A'}</code>
              <button type="button" class="copy-btn" onclick="depositsPage.copyAddress('${method.address}')">
                Copy Address
              </button>
            </div>
          </div>
        </div>
      `;
    }
    
    if (method.method_type === 'ach') {
      return `
        <div class="payment-details">
          <h4>Bank Information</h4>
          <div class="detail-row">
            <label>Bank Name:</label>
            <div class="detail-value">${method.bank_name || 'N/A'}</div>
          </div>
          <div class="detail-row">
            <label>Account Number:</label>
            <div class="detail-value">${method.account_number || 'N/A'}</div>
          </div>
          <div class="detail-row">
            <label>Routing Number:</label>
            <div class="detail-value">${method.routing_number || 'N/A'}</div>
          </div>
        </div>
      `;
    }
    
    if (method.method_type === 'paypal') {
      return `
        <div class="payment-details">
          <h4>PayPal Information</h4>
          <div class="detail-row">
            <label>Email:</label>
            <div class="detail-value">${method.paypal_email || 'N/A'}</div>
          </div>
          <div class="detail-row">
            <label>Business Name:</label>
            <div class="detail-value">${method.paypal_business_name || 'N/A'}</div>
          </div>
        </div>
      `;
    }
    
    return '';
  }

  renderActionButtons() {
    const isUpgrade = this.tierUpgradeContext?.target === 'tier_upgrade';
    
    return `
      <div class="action-buttons">
        <button type="button" class="btn btn-secondary" onclick="depositsPage.closeDepositForm()">
          Cancel
        </button>
        <button type="button" class="btn btn-primary" onclick="depositsPage.initiateDeposit()" id="deposit-submit-btn">
          ${isUpgrade ? 'Upgrade Account' : 'Deposit Funds'}
        </button>
      </div>
    `;
  }

  setupFormValidation() {
    const amountInput = document.getElementById('deposit-amount');
    if (!amountInput) return;

    amountInput.addEventListener('input', (e) => {
      this.updateDepositAmount(e.target.value);
    });

    // Remove any existing modals
    this.closeDepositModal();
  }

  updateDepositAmount(amount) {
    this.currentDepositAmount = parseFloat(amount) || 0;
    const submitBtn = document.getElementById('deposit-submit-btn');
    if (submitBtn) {
      submitBtn.textContent = `${this.tierUpgradeContext?.target === 'tier_upgrade' ? 'Upgrade Account' : 'Deposit Funds'} (${this.formatMoney(this.currentDepositAmount, this.selectedMethod.currency === 'USDT' ? 6 : this.selectedMethod.currency === 'BTC' ? 8 : 2)})`;
    }
  }

  closeDepositForm() {
    const container = document.getElementById('deposit-form');
    if (container) {
      container.innerHTML = '';
    }
  }

  async initiateDeposit() {
    if (!this.selectedMethod) {
      if (window.Notify) {
        window.Notify.error('Please select a deposit method');
      }
      return;
    }

    // Validate amount
    if (!this.currentDepositAmount || this.currentDepositAmount < (this.selectedMethod.min_amount || (this.selectedMethod.currency === 'BTC' ? 100 : 1))) {
      const minAmount = this.selectedMethod.min_amount || (this.selectedMethod.currency === 'BTC' ? 100 : 1);
      if (window.Notify) {
        window.Notify.error(`Minimum deposit amount is ${this.getCurrencySymbol(this.selectedMethod.currency)}${this.formatMoney(minAmount, this.selectedMethod.currency === 'USDT' ? 6 : this.selectedMethod.currency === 'BTC' ? 8 : 2)}`);
      }
      return;
    }

    if (this.selectedMethod.max_amount && this.currentDepositAmount > this.selectedMethod.max_amount) {
      if (window.Notify) {
        window.Notify.error(`Maximum deposit amount is ${this.getCurrencySymbol(this.selectedMethod.currency)}${this.formatMoney(this.selectedMethod.max_amount, this.selectedMethod.currency === 'USDT' ? 6 : this.selectedMethod.currency === 'BTC' ? 8 : 2)}`);
      }
      return;
    }

    // Show loading state
    this.showLoadingModal();

    try {
      const userId = await this.api.getCurrentUserId();
      
      const depositData = {
        user_id: userId,
        method_id: this.selectedMethod.id,
        method_name: this.selectedMethod.method_name,
        method_type: this.selectedMethod.method_type,
        currency: this.selectedMethod.currency,
        amount: this.currentDepositAmount,
        network: this.selectedMethod.network,
        address: this.selectedMethod.address,
        bank_name: this.selectedMethod.bank_name,
        account_number: this.selectedMethod.account_number,
        routing_number: this.selectedMethod.routing_number,
        paypal_email: this.selectedMethod.paypal_email
      };

      const response = await this.api.createDepositRequest(depositData);
      
      if (response.success) {
        this.showSuccessModal();
        // Reset form
        document.getElementById('deposit-form-element').reset();
        this.selectedMethod = null;
      } else {
        this.showErrorModal(response.error || 'Failed to submit deposit request');
      }
    } catch (error) {
      console.error('Deposit submission error:', error);
      this.showErrorModal('Failed to submit deposit request');
    }
  }

  showLoadingModal() {
    this.showModal(`
      <div class="loading-modal">
        <div class="loading-spinner"></div>
        <h3>Processing Deposit</h3>
        <p>Please wait while we process your deposit request...</p>
      </div>
    `, false);
  }

  showSuccessModal() {
    this.showModal(`
      <div class="success-modal">
        <div class="success-icon">✓</div>
        <h3>Deposit Submitted Successfully</h3>
        <p>Your deposit request has been submitted for approval.</p>
        <p>You will receive a notification once your deposit is processed.</p>
        <button type="button" class="btn btn-primary" onclick="depositsPage.closeModal()">
          Close
        </button>
      </div>
    `, false);
  }

  showErrorModal(message) {
    this.showModal(`
      <div class="error-modal">
        <div class="error-icon">⚠</div>
        <h3>Deposit Failed</h3>
        <p>${message}</p>
        <p>Please try again or contact support if the problem persists.</p>
        <button type="button" class="btn btn-secondary" onclick="depositsPage.closeModal()">
          Close
        </button>
      </div>
    `, false);
  }

  showModal(content, showCloseButton = true) {
    let modal = document.getElementById('deposit-modal');
    if (!modal) {
      modal = document.createElement('div');
      modal.id = 'deposit-modal';
      modal.className = 'modal';
      modal.innerHTML = content;
      document.body.appendChild(modal);
    } else {
      modal.innerHTML = content;
    }

    modal.style.display = 'flex';
    
    // Add close button if requested
    if (showCloseButton) {
      const closeBtn = document.createElement('button');
      closeBtn.className = 'modal-close';
      closeBtn.innerHTML = '×';
      closeBtn.onclick = () => this.closeModal();
      modal.appendChild(closeBtn);
    }

    // Animate in
    setTimeout(() => {
      modal.classList.add('active');
    }, 10);
  }

  closeModal() {
    const modal = document.getElementById('deposit-modal');
    if (modal) {
      modal.classList.remove();
    }
  }

  copyAddress(address) {
    if (!address) {
      if (window.Notify) {
        window.Notify.error('No address to copy');
      }
      return;
    }
    
    navigator.clipboard.writeText(address).then(() => {
      if (window.Notify) {
        window.Notify.success('Address copied to clipboard!');
      }
    }).catch(() => {
      if (window.Notify) {
        window.Notify.error('Failed to copy address');
      }
    });
  }

  formatMoney(amount, decimals = 2) {
    if (amount === null || amount === undefined) return '0.00';
    
    const num = parseFloat(amount);
    if (isNaN(num)) return '0.00';
    
    const fixed = num.toFixed(decimals);
    const parts = fixed.split('.');
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return parts.join('.');
  }

  setupURLParameters() {
    const urlParams = new URLSearchParams(window.location.search);
    const amount = urlParams.get('amount');
    const currency = urlParams.get('currency');
    const target = urlParams.get('target');
    const tierId = urlParams.get('tier_id');

    if (amount && currency === 'USDT' && target === 'tier_upgrade' && tierId) {
      this.prefillForTierUpgrade(amount, tierId);
    }
  }

  prefilledForTierUpgrade(amount, tierId) {
    this.tierUpgradeContext = {
      target: 'tier_upgrade',
      tier_id: parseInt(tierId),
      amount: parseFloat(amount)
    };
    
    console.log('Tier upgrade context set:', this.tierUpgradeContext);
  }

  showError(message) {
    const container = document.getElementById('deposit-methods');
    if (container) {
      container.innerHTML = `
        <div class="error-message">
          <h3>Error</h3>
          <p>${message}</p>
        </div>
      `;
    }
  }

  setupForms() {
    // Minimal setup since we're using modal-based approach
    console.log('Deposit forms setup complete - using modal system');
  }

  // Cleanup method
  destroy() {
    console.log('Deposits page cleanup');
    // Close any open modals
    this.closeModal();
  }
}

// Initialize page controller
window.depositsPage = new DepositsPage();

// Export for potential testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = DepositsPage;
}
