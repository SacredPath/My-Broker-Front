/**
 * Deposits Page Controller
 * Handles deposit methods, payment processing, and transaction tracking
 */

// Import shared app initializer
import '/public/assets/js/_shared/app_init.js';

class DepositsPage {
  constructor() {
    this.selectedMethod = null;
    this.currentUser = null;
    this.depositSettings = null;
    this.currentOrder = null;
    this.timerInterval = null;
    this.init();
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
      // Initialize app shell (sidebar, navigation, etc.)
      if (window.AppShell) {
        window.AppShell.initShell();
      }
      
      // Load data
      await this.loadUserData();
      await this.loadDepositSettings();
      
      // Setup UI
      this.setupMethodCards();
      this.setupForms();
      this.setupURLParameters();
      
      console.log('Deposits page setup complete');
    } catch (error) {
      console.error('Error setting up deposits page:', error);
      if (window.Notify) {
        window.Notify.error('Failed to load deposit options');
      }
    }
  }

  loadAppShell() {
    const shellContainer = document.getElementById('app-shell-container');
    if (shellContainer) {
      fetch('/src/components/app-shell.html')
        .then(response => response.text())
        .then(html => {
          shellContainer.innerHTML = html;
          
          if (window.AppShell) {
            window.AppShell.setupShell();
          }
        })
        .catch(error => {
          console.error('Failed to load app shell:', error);
        });
    }
  }

  async loadUserData() {
    try {
      this.currentUser = await window.AuthService.getCurrentUserWithProfile();
      
      if (!this.currentUser) {
        throw new Error('User not authenticated');
      }
    } catch (error) {
      console.error('Failed to load user data:', error);
      throw error;
    }
  }

  async loadDepositSettings() {
    try {
      // Fetch deposit settings from app_settings
      const { data, error } = await window.API.fetchEdge('deposit_settings', {
        method: 'GET'
      });

      if (error) {
        throw error;
      }

      // Use real settings from database
      const settings = data.settings || {};
      this.depositSettings = {
        methods: {
          usdt_trc20: {
            enabled: true,
            name: 'USDT TRC20',
            description: 'Direct USDT transfer',
            features: [`${settings.usdt_match_window_minutes || 30}-minute window`, 'Auto-detection'],
            min_amount: 10,
            matching_window_minutes: settings.usdt_match_window_minutes || 30,
            address: settings.usdt_trc20_address,
            overpay_tolerance: settings.usdt_overpay_tolerance || 5000
          },
          stripe: {
            enabled: true,
            name: 'Stripe Payment',
            description: 'Credit/debit card payment',
            features: ['Instant verification', 'Secure processing'],
            min_amount: 50,
            payment_link: settings.stripe_hosted_link
          },
          paypal: {
            enabled: true,
            name: 'PayPal Invoice',
            description: 'PayPal invoice system',
            features: ['Invoice generation', 'Global support'],
            min_amount: 50,
            invoice_link: settings.paypal_invoice_link
          },
          bank: {
            enabled: true,
            name: 'Bank Transfer',
            description: 'Direct bank transfer',
            features: ['Manual verification', 'Supports all banks'],
            min_amount: 100,
            details: settings.bank_details
          }
        }
      };
    } catch (error) {
      console.error('Failed to load deposit settings:', error);
      
      // Handle 401/Authentication errors
      if (error.code === 'AUTH_REQUIRED' || error.message.includes('401') || error.message.includes('Authentication required')) {
        this.showSessionExpiredModal();
        return;
      }
      
      // Show empty state for other errors
      this.renderEmptyState('Failed to load deposit options');
    }
  }

  showSessionExpiredModal() {
    if (window.showModal) {
      window.showModal({
        title: 'Session expired',
        message: 'Please log in again to continue.',
        primaryText: 'Go to login',
        primaryAction: () => {
          window.location.href = '/login.html';
        }
      });
    } else {
      alert('Session expired. Please log in again.');
      window.location.href = '/login.html';
    }
  }

  renderEmptyState(message) {
    const methodsContainer = document.getElementById('deposit-methods');
    if (!methodsContainer) return;
    
    methodsContainer.innerHTML = `
      <div class="empty-state">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"></circle>
          <line x1="15" y1="9" x2="9" y2="15"></line>
          <line x1="9" y1="9" x2="15" y2="15"></line>
        </svg>
        <h3>Deposit options unavailable</h3>
        <p>${message}</p>
      </div>
    `;
  }

  setupMethodCards() {
    const methodsContainer = document.getElementById('deposit-methods');
    if (!methodsContainer) return;

    const methods = [
      {
        id: 'bank',
        name: this.depositSettings.methods.bank.name,
        description: this.depositSettings.methods.bank.description,
        features: this.depositSettings.methods.bank.features,
        icon: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="7" y1="21" x2="17" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>'
      },
      {
        id: 'stripe',
        name: this.depositSettings.methods.stripe.name,
        description: this.depositSettings.methods.stripe.description,
        features: this.depositSettings.methods.stripe.features,
        icon: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect><line x1="1" y1="10" x2="23" y2="10"></line></svg>'
      },
      {
        id: 'paypal',
        name: this.depositSettings.methods.paypal.name,
        description: this.depositSettings.methods.paypal.description,
        features: this.depositSettings.methods.paypal.features,
        icon: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M7 16V4a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v8"></path><path d="M12 14H7a2 2 0 0 0-2 2v4a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-4a2 2 0 0 0-2-2h-3"></path></svg>'
      },
      {
        id: 'usdt_trc20',
        name: this.depositSettings.methods.usdt_trc20.name,
        description: this.depositSettings.methods.usdt_trc20.description,
        features: this.depositSettings.methods.usdt_trc20.features,
        icon: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><path d="M12 6v6l4 2"></path></svg>'
      }
    ];

    methodsContainer.innerHTML = methods.map(method => `
      <div class="method-card" data-method="${method.id}" onclick="window.depositsPage.selectMethod('${method.id}')">
        <div class="method-header">
          <div class="method-icon">${method.icon}</div>
          <div class="method-info">
            <div class="method-name">${method.name}</div>
            <div class="method-description">${method.description}</div>
          </div>
        </div>
        <div class="method-features">
          ${method.features.map(feature => `
            <div class="feature-item">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="20 6 9 17 4 12"></polyline>
              </svg>
              ${feature}
            </div>
          `).join('')}
        </div>
      </div>
    `).join('');
  }

  setupForms() {
    // Setup amount input listeners for conversion preview
    const amountInputs = document.querySelectorAll('.amount-input');
    amountInputs.forEach(input => {
      input.addEventListener('input', (e) => {
        const formId = e.target.id.replace('-amount', '');
        this.updateConversionPreview(formId, e.target.value);
      });
    });

    // Setup file upload for bank method
    const bankFileInput = document.getElementById('bank-proof-file');
    if (bankFileInput) {
      bankFileInput.addEventListener('change', (e) => this.handleFileUpload(e));
    }
  }

  setupURLParameters() {
    // Handle URL parameters for tier upgrade CTAs
    const urlParams = new URLSearchParams(window.location.search);
    const amount = urlParams.get('amount');
    const currency = urlParams.get('currency');
    const target = urlParams.get('target');
    const tierId = urlParams.get('tier_id');

    if (amount && currency === 'USDT' && target === 'tier_upgrade' && tierId) {
      // Pre-fill amount and select appropriate method
      this.prefillForTierUpgrade(amount, tierId);
    }
  }

  prefillForTierUpgrade(amount, tierId) {
    // Select USDT method for tier upgrades
    this.selectMethod('usdt_trc20');
    
    // Pre-fill amount
    const usdtInput = document.getElementById('usdt-amount');
    if (usdtInput) {
      usdtInput.value = amount;
      this.updateConversionPreview('usdt', amount);
    }

    // Store tier upgrade context
    this.tierUpgradeContext = {
      target: 'tier_upgrade',
      tier_id: parseInt(tierId),
      amount: parseFloat(amount)
    };
  }

  selectMethod(methodId) {
    // Update selected method
    this.selectedMethod = methodId;

    // Update UI
    const methodCards = document.querySelectorAll('.method-card');
    methodCards.forEach(card => {
      card.classList.remove('selected');
    });
    
    const selectedCard = document.querySelector(`[data-method="${methodId}"]`);
    if (selectedCard) {
      selectedCard.classList.add('selected');
    }

    // Show corresponding form
    const forms = document.querySelectorAll('.deposit-form');
    forms.forEach(form => {
      form.classList.remove('active');
    });
    
    const selectedForm = document.getElementById(`${methodId}-form`);
    if (selectedForm) {
      selectedForm.classList.add('active');
    }
  }

  async updateConversionPreview(formId, amount) {
    if (!amount || parseFloat(amount) <= 0) {
      const preview = document.getElementById(`${formId}-conversion`);
      if (preview) {
        preview.style.display = 'none';
      }
      return;
    }

    const usdtAmount = parseFloat(amount);
    const conversion = await this.calculateConversion(usdtAmount);
    
    const preview = document.getElementById(`${formId}-conversion`);
    if (preview) {
      if (conversion.error) {
        preview.innerHTML = `
          <div class="conversion-row">
            <span class="conversion-label">Conversion Error:</span>
            <span class="conversion-value" style="color: var(--error-color)">${conversion.error}</span>
          </div>
        `;
      } else {
        preview.innerHTML = `
          <div class="conversion-row">
            <span class="conversion-label">USDT Amount:</span>
            <span class="conversion-value">₮${this.formatMoney(usdtAmount, 6)}</span>
          </div>
          <div class="conversion-row">
            <span class="conversion-label">USD Received:</span>
            <span class="conversion-value">$${this.formatMoney(conversion.usdReceived)}</span>
          </div>
          <div class="conversion-row">
            <span class="conversion-label">Exchange Rate:</span>
            <span class="conversion-value">1 USDT = $${this.formatMoney(conversion.liveRate || 1.0, 6)}</span>
          </div>
          <div class="conversion-row">
            <span class="conversion-label">Markup:</span>
            <span class="conversion-value conversion-fee">$${this.formatMoney(conversion.markup)}</span>
          </div>
          <div class="conversion-row">
            <span class="conversion-label">Fixed Fee:</span>
            <span class="conversion-value conversion-fee">$${this.formatMoney(conversion.fixedFee)}</span>
          </div>
          <div class="conversion-row">
            <span class="conversion-label">Variable Fee:</span>
            <span class="conversion-value conversion-fee">$${this.formatMoney(conversion.variableFee)}</span>
          </div>
          <div class="conversion-row">
            <span class="conversion-label">Total Fees:</span>
            <span class="conversion-value conversion-fee">$${this.formatMoney(conversion.totalFees)}</span>
          </div>
        `;
      }
      preview.style.display = 'block';
    }
  }

  async calculateConversion(usdtAmount) {
    const settings = this.depositSettings.conversion;
    
    try {
      // Get real live rate from API
      const { data, error } = await window.API.fetchEdge('exchange_rate', {
        method: 'GET',
        params: {
          from: 'USDT',
          to: 'USD'
        }
      });

      if (error) {
        throw error;
      }

      const liveRate = data.rate || 1.0;
      const usdEquivalent = usdtAmount * liveRate;
      const markup = usdEquivalent * (settings.markup_percentage / 100);
      const fixedFee = settings.fixed_fee_usd;
      const variableFee = usdEquivalent * (settings.variable_fee_percentage / 100);
      const totalFees = markup + fixedFee + variableFee;
      const usdReceived = usdEquivalent - totalFees;
      
      return {
        usdEquivalent,
        markup,
        fixedFee,
        variableFee,
        totalFees,
        usdReceived,
        liveRate
      };
    } catch (error) {
      console.error('Failed to get exchange rate:', error);
      // Return error state
      return {
        usdEquivalent: 0,
        markup: 0,
        fixedFee: 0,
        variableFee: 0,
        totalFees: 0,
        usdReceived: 0,
        error: 'Rate unavailable'
      };
    }
  }

  handleFileUpload(event) {
    const file = event.target.files[0];
    if (!file) return;

    // Validate file type
    if (!file.type.match(/image\/jpeg|image\/jpg/)) {
      window.Notify.error('Please upload a JPG image');
      event.target.value = '';
      return;
    }

    // Validate file size (5MB)
    if (file.size > 5 * 1024 * 1024) {
      window.Notify.error('File size must be less than 5MB');
      event.target.value = '';
      return;
    }

    // Update UI
    const upload = document.getElementById('bank-proof-upload');
    const fileInfo = document.getElementById('bank-file-info');
    const fileName = document.getElementById('bank-file-name');
    const fileSize = document.getElementById('bank-file-size');

    upload.classList.add('has-file');
    fileInfo.style.display = 'flex';
    fileName.textContent = file.name;
    fileSize.textContent = this.formatFileSize(file.size);

    // Store file reference
    this.bankProofFile = file;
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  async submitBankDeposit() {
    const amount = document.getElementById('bank-amount').value;
    
    if (!amount || parseFloat(amount) <= 0) {
      window.Notify.error('Please enter a valid amount');
      return;
    }

    if (!this.bankProofFile) {
      window.Notify.error('Please upload proof of payment');
      return;
    }

    try {
      this.setButtonLoading('bank-submit-btn', true);

      // Create deposit order
      const { data, error } = await window.API.fetchEdge('deposit_create_order', {
        method: 'POST',
        body: {
          method: 'bank',
          amount: parseFloat(amount),
          currency: 'USDT',
          proof_file: this.bankProofFile,
          tier_upgrade_context: this.tierUpgradeContext
        }
      });

      if (error) {
        throw error;
      }

      // Upload proof file to storage
      await this.uploadProofFile(data.order_id, this.bankProofFile);

      // Show success message
      window.Notify.success('Bank deposit submitted successfully! Your deposit will be reviewed by our team.');

      // Reset form
      this.resetForm('bank');

    } catch (error) {
      console.error('Bank deposit failed:', error);
      window.Notify.error(error.message || 'Failed to submit bank deposit');
    } finally {
      this.setButtonLoading('bank-submit-btn', false);
    }
  }

  async submitStripeDeposit() {
    const amount = document.getElementById('stripe-amount').value;
    
    if (!amount || parseFloat(amount) <= 0) {
      window.Notify.error('Please enter a valid amount');
      return;
    }

    try {
      this.setButtonLoading('stripe-submit-btn', true);

      // Create deposit order
      const { data, error } = await window.API.fetchEdge('deposit_create_order', {
        method: 'POST',
        body: {
          method: 'stripe',
          amount: parseFloat(amount),
          currency: 'USDT',
          tier_upgrade_context: this.tierUpgradeContext
        }
      });

      if (error) {
        throw error;
      }

      // Redirect to Stripe payment link
      const paymentLink = this.depositSettings.methods.stripe.payment_link;
      window.open(`${paymentLink}?amount=${amount}&order_id=${data.order_id}`, '_blank');

      // Show success message
      window.Notify.info('Redirecting to Stripe for payment...');

    } catch (error) {
      console.error('Stripe deposit failed:', error);
      window.Notify.error(error.message || 'Failed to initiate Stripe payment');
    } finally {
      this.setButtonLoading('stripe-submit-btn', false);
    }
  }

  async submitPayPalDeposit() {
    const amount = document.getElementById('paypal-amount').value;
    
    if (!amount || parseFloat(amount) <= 0) {
      window.Notify.error('Please enter a valid amount');
      return;
    }

    try {
      this.setButtonLoading('paypal-submit-btn', true);

      // Create deposit order
      const { data, error } = await window.API.fetchEdge('deposit_create_order', {
        method: 'POST',
        body: {
          method: 'paypal',
          amount: parseFloat(amount),
          currency: 'USDT',
          tier_upgrade_context: this.tierUpgradeContext
        }
      });

      if (error) {
        throw error;
      }

      // Redirect to PayPal invoice
      const invoiceLink = this.depositSettings.methods.paypal.invoice_link;
      window.open(`${invoiceLink}?amount=${amount}&order_id=${data.order_id}`, '_blank');

      // Show success message
      window.Notify.info('Generating PayPal invoice...');

    } catch (error) {
      console.error('PayPal deposit failed:', error);
      window.Notify.error(error.message || 'Failed to generate PayPal invoice');
    } finally {
      this.setButtonLoading('paypal-submit-btn', false);
    }
  }

  async submitUSDTDeposit() {
    const amount = document.getElementById('usdt-amount').value;
    
    if (!amount || parseFloat(amount) <= 0) {
      window.Notify.error('Please enter a valid amount');
      return;
    }

    try {
      this.setButtonLoading('usdt-submit-btn', true);

      // Create deposit order with unique amount using real endpoint
      const { data, error } = await window.API.fetchEdge('deposit_create_order', {
        method: 'POST',
        body: {
          method: 'usdt_trc20',
          currency: 'USDT',
          expected_amount: parseFloat(amount)
        }
      });

      if (error) {
        throw error;
      }

      this.currentOrder = data;

      // Show QR code and address
      this.showUSDTDepositInfo(data);

      // Start timer
      this.startTimer(this.depositSettings.methods.usdt_trc20.matching_window_minutes);

      // Start monitoring for deposit
      this.monitorUSDTDeposit(data.deposit_id);

    } catch (error) {
      console.error('USDT deposit failed:', error);
      window.Notify.error(error.detail || error.message || 'Failed to generate deposit address');
    } finally {
      this.setButtonLoading('usdt-submit-btn', false);
    }
  }

  showUSDTDepositInfo(orderData) {
    const qrCode = document.getElementById('usdt-qr-code');
    const address = document.getElementById('usdt-address');
    const timer = document.getElementById('usdt-timer');
    const status = document.getElementById('usdt-status');
    const submitBtn = document.getElementById('usdt-submit-btn');

    // Use real payment instructions from endpoint
    const paymentInstructions = orderData.payment_instructions;
    if (!paymentInstructions) {
      window.Notify.error('Payment instructions not available');
      return;
    }

    // Use real address from payment_instructions or fallback to settings
    const depositAddress = paymentInstructions.address || this.depositSettings.methods.usdt_trc20.address;
    if (!depositAddress) {
      window.Notify.error('Deposit address not configured');
      return;
    }

    // Generate QR code for address
    const qrImage = document.getElementById('qr-image');
    qrImage.src = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${depositAddress}`;

    // Show address and amount
    address.textContent = depositAddress;
    
    // Show unique amount if available
    const amountDisplay = document.getElementById('usdt-amount-display');
    if (amountDisplay && paymentInstructions.amount) {
      amountDisplay.textContent = `Amount: ₮${this.formatMoney(paymentInstructions.amount, 6)}`;
    }

    // Show elements
    qrCode.style.display = 'block';
    timer.style.display = 'block';
    status.style.display = 'block';

    // Hide submit button
    submitBtn.style.display = 'none';

    // Update status
    this.updateDepositStatus('pending', 'Waiting for payment', `Transfer ₮${this.formatMoney(paymentInstructions.amount, 6)} to the address above`);
  }

  startTimer(minutes) {
    let remainingSeconds = minutes * 60;
    
    this.timerInterval = setInterval(() => {
      const minutes = Math.floor(remainingSeconds / 60);
      const seconds = remainingSeconds % 60;
      const display = `${minutes}:${seconds.toString().padStart(2, '0')}`;
      
      const timerElement = document.getElementById('timer-remaining');
      if (timerElement) {
        timerElement.textContent = display;
      }

      if (remainingSeconds <= 0) {
        clearInterval(this.timerInterval);
        this.handleTimerExpired();
      }

      remainingSeconds--;
    }, 1000);
  }

  handleTimerExpired() {
    const timer = document.getElementById('usdt-timer');
    if (timer) {
      timer.classList.add('expired');
      timer.innerHTML = 'Payment window expired';
    }

    this.updateDepositStatus('error', 'Payment Expired', 'The payment window has expired. Please generate a new deposit address.');
  }

  async monitorUSDTDeposit(orderId) {
    // Poll for deposit confirmation
    const pollInterval = setInterval(async () => {
      try {
        const { data, error } = await window.API.fetchEdge('usdt_watch_trc20', {
          method: 'GET',
          params: { order_id: orderId }
        });

        if (error) {
          throw error;
        }

        if (data.status === 'confirmed') {
          clearInterval(pollInterval);
          clearInterval(this.timerInterval);
          this.handleDepositConfirmed(data);
        } else if (data.status === 'detected') {
          this.updateDepositStatus('pending', 'Payment Detected', 'Payment detected, awaiting confirmation...');
        }

      } catch (error) {
        console.error('Error monitoring deposit:', error);
      }
    }, 5000); // Poll every 5 seconds
  }

  handleDepositConfirmed(data) {
    this.updateDepositStatus('completed', 'Payment Confirmed', `Payment of ${data.amount} USDT confirmed and converted to USD`);
    
    // Show success message
    window.Notify.success('Deposit confirmed! Funds have been added to your account.');

    // Handle tier upgrade if applicable
    if (this.tierUpgradeContext) {
      this.handleTierUpgradeCompletion();
    }

    // Reset form after delay
    setTimeout(() => {
      this.resetForm('usdt');
    }, 5000);
  }

  handleTierUpgradeCompletion() {
    // Auto-complete tier upgrade after conversion
    window.Notify.success('Tier upgrade completed successfully!');
    
    // Clear tier upgrade context
    this.tierUpgradeContext = null;
  }

  updateDepositStatus(status, title, description) {
    const statusContainer = document.getElementById('usdt-status');
    if (!statusContainer) return;

    const statusIcons = {
      pending: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>',
      completed: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>',
      error: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>'
    };

    statusContainer.innerHTML = `
      <div class="status-item">
        <div class="status-icon ${status}">
          ${statusIcons[status]}
        </div>
        <div class="status-text">
          <div class="status-title">${title}</div>
          <div class="status-description">${description}</div>
        </div>
      </div>
    `;
  }

  copyAddress() {
    const address = document.getElementById('usdt-address');
    if (!address) return;

    navigator.clipboard.writeText(address.textContent).then(() => {
      const copyBtn = document.querySelector('.copy-button');
      if (copyBtn) {
        copyBtn.textContent = 'Copied!';
        copyBtn.classList.add('copied');
        
        setTimeout(() => {
          copyBtn.textContent = 'Copy Address';
          copyBtn.classList.remove('copied');
        }, 2000);
      }
    });
  }

  async uploadProofFile(orderId, file) {
    // Upload file to Supabase Storage
    const fileName = `deposits/${orderId}/proof_${Date.now()}.jpg`;
    
    const { error } = await window.supabaseClient.storage
      .from('DEPOSITS_KEEP')
      .upload(fileName, file);

    if (error) {
      throw error;
    }

    return fileName;
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
      button.textContent = button.textContent.replace('Processing...', 'Submit');
    }
  }

  resetForm(formId) {
    // Reset form inputs
    const form = document.getElementById(`${formId}-form`);
    if (form) {
      const inputs = form.querySelectorAll('input');
      inputs.forEach(input => {
        input.value = '';
        input.disabled = false;
      });
    }

    // Reset file upload
    if (formId === 'bank') {
      const upload = document.getElementById('bank-proof-upload');
      const fileInfo = document.getElementById('bank-file-info');
      
      if (upload) upload.classList.remove('has-file');
      if (fileInfo) fileInfo.style.display = 'none';
      
      this.bankProofFile = null;
    }

    // Reset USDT specific elements
    if (formId === 'usdt') {
      const qrCode = document.getElementById('usdt-qr-code');
      const timer = document.getElementById('usdt-timer');
      const status = document.getElementById('usdt-status');
      const submitBtn = document.getElementById('usdt-submit-btn');

      if (qrCode) qrCode.style.display = 'none';
      if (timer) timer.style.display = 'none';
      if (status) status.style.display = 'none';
      if (submitBtn) submitBtn.style.display = 'block';

      // Clear intervals
      if (this.timerInterval) {
        clearInterval(this.timerInterval);
      }
    }

    // Hide conversion preview
    const preview = document.getElementById(`${formId}-conversion`);
    if (preview) {
      preview.style.display = 'none';
    }

    // Clear current order
    this.currentOrder = null;
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
    console.log('Deposits page cleanup');
    
    // Clear intervals
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }
  }
}

// Initialize page controller
window.depositsPage = new DepositsPage();

// Export for potential testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = DepositsPage;
}
