/**
 * Login Page Controller
 * Handles form submission and authentication
 */

class LoginController {
  constructor() {
    this.init();
  }

  async init() {
    console.log('Login page initializing...');
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupPage());
    } else {
      this.setupPage();
    }
  }

  async setupPage() {
    try {
      // Setup theme toggle
      this.setupThemeToggle();
      
      // Setup login form
      this.setupLoginForm();
      
      // Setup Google login
      this.setupGoogleLogin();
      
      // Setup forgot password
      this.setupForgotPassword();
      
      // Setup signup link
      this.setupSignupLink();
      
      // Check if user is already logged in
      await this.checkExistingAuth();
      
      console.log('Login page setup complete');
    } catch (error) {
      console.error('Error setting up login page:', error);
      if (window.Notify) {
        window.Notify.error('Failed to load login page properly');
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
    return newTheme;
  }

  setupLoginForm() {
    const loginForm = document.getElementById('login-form');
    const loginBtn = document.getElementById('login-btn');
    const loginBtnText = document.getElementById('login-btn-text');
    const loginSpinner = document.getElementById('login-spinner');

    if (!loginForm) return;

    // Prevent duplicate event listeners
    if (loginForm.hasAttribute('data-listener-attached')) {
      return;
    }
    loginForm.setAttribute('data-listener-attached', 'true');

    let isSubmitting = false;

    loginForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      // Prevent double-submit
      if (isSubmitting) {
        console.debug('[login] submit ignored - already in flight');
        return;
      }

      // Get and normalize inputs
      const emailInput = document.getElementById('email');
      const passwordInput = document.getElementById('password');
      
      if (!emailInput || !passwordInput) {
        this.showInlineError('Form fields not found');
        return;
      }

      const email = emailInput.value.trim().toLowerCase();
      const password = passwordInput.value; // Do NOT trim password

      // Validate inputs before calling AuthService
      if (!email) {
        this.showInlineError('Enter your email');
        return;
      }

      if (!password) {
        this.showInlineError('Enter your password');
        return;
      }

      // Safe debug logging (no sensitive data)
      console.debug('[login] submit', {
        email_len: email.length,
        email_domain: email.split('@')[1] ?? null,
        has_password: !!password,
        password_len: password.length
      });

      isSubmitting = true;

      // Show loading state
      if (loginBtn) {
        loginBtn.disabled = true;
        if (loginBtnText) loginBtnText.style.display = 'none';
        if (loginSpinner) loginSpinner.style.display = 'block';
      }

      // Clear any previous errors
      this.clearInlineError();

      try {
        // Attempt login
        const result = await window.AuthService.loginWithEmailPassword(email, password);
        
        if (result.success) {
          console.log('Login successful, redirecting to dashboard...');
          // Redirect is handled in auth.js
        } else {
          console.error('Login failed:', result.error);
          this.handleLoginError(result.error);
        }
      } catch (error) {
        console.error('Login error:', error);
        this.handleLoginError(error);
      } finally {
        isSubmitting = false;
        
        // Reset loading state
        if (loginBtn) {
          loginBtn.disabled = false;
          if (loginBtnText) loginBtnText.style.display = 'inline';
          if (loginSpinner) loginSpinner.style.display = 'none';
        }
      }
    });
  }

  handleLoginError(error) {
    const errorMessage = error.message || 'Login failed';
    
    // Show all errors as inline messages (no verification modal per rule B)
    this.showInlineError(errorMessage);
  }

  showInlineError(message) {
    // Remove existing error
    this.clearInlineError();
    
    // Create or update error message area
    let errorDiv = document.getElementById('login-error');
    if (!errorDiv) {
      errorDiv = document.createElement('div');
      errorDiv.id = 'login-error';
      errorDiv.className = 'alert alert-danger mt-3';
      errorDiv.style.cssText = `
        padding: 12px 16px;
        border-radius: 6px;
        background-color: #fee;
        border: 1px solid #fcc;
        color: #c33;
        font-size: 14px;
        margin-top: 12px;
        display: flex;
        justify-content: space-between;
        align-items: center;
      `;
      
      // Insert after the form or before the submit button
      const loginForm = document.getElementById('login-form');
      const submitButton = document.getElementById('login-btn');
      if (submitButton && submitButton.parentNode) {
        submitButton.parentNode.insertBefore(errorDiv, submitButton);
      } else if (loginForm) {
        loginForm.appendChild(errorDiv);
      }
    }
    
    errorDiv.innerHTML = `
      <span>${message}</span>
      <button type="button" onclick="this.parentElement.remove()" style="
        background: none;
        border: none;
        color: #c33;
        font-size: 18px;
        cursor: pointer;
        padding: 0;
        margin-left: 8px;
      ">×</button>
    `;
  }

  clearInlineError() {
    const errorDiv = document.getElementById('login-error');
    if (errorDiv) {
      errorDiv.remove();
    }
  }

  setupGoogleLogin() {
    const googleLoginBtn = document.getElementById('google-login-btn');
    const googleBtnText = document.getElementById('google-btn-text');
    const googleSpinner = document.getElementById('google-spinner');

    if (!googleLoginBtn) return;

    googleLoginBtn.addEventListener('click', async () => {
      // Show loading state
      googleLoginBtn.disabled = true;
      if (googleBtnText) googleBtnText.style.display = 'none';
      if (googleSpinner) googleSpinner.style.display = 'block';

      try {
        const result = await window.AuthService.loginWithGoogle();
        
        if (result.success) {
          console.log('Google login initiated');
        } else {
          console.error('Google login failed:', result.error);
          this.showInlineError(result.error.message || 'Google login failed');
        }
      } catch (error) {
        console.error('Google login error:', error);
        this.showInlineError('Google login failed. Please try again.');
      } finally {
        // Reset loading state
        googleLoginBtn.disabled = false;
        if (googleBtnText) googleBtnText.style.display = 'inline';
        if (googleSpinner) googleSpinner.style.display = 'none';
      }
    });
  }

  setupForgotPassword() {
    // Use event delegation for password reset button
    document.addEventListener('click', async (e) => {
      if (e.target.closest('[data-action="password-reset"]')) {
        e.preventDefault();
        this.showPasswordResetModal();
      }
    });

    // Setup modal event listeners
    this.setupModalListeners();
  }

  setupModalListeners() {
    const modal = document.getElementById('password-reset-modal');
    const closeBtn = document.getElementById('close-modal-btn');
    const cancelBtn = document.getElementById('cancel-reset-btn');
    const form = document.getElementById('password-reset-form');
    const closeSuccessBtn = document.getElementById('close-success-btn');

    // Close modal handlers
    const closeModal = () => this.hidePasswordResetModal();
    closeBtn?.addEventListener('click', closeModal);
    cancelBtn?.addEventListener('click', closeModal);
    closeSuccessBtn?.addEventListener('click', closeModal);

    // Close on backdrop click
    modal?.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeModal();
      }
    });

    // Form submission
    form?.addEventListener('submit', async (e) => {
      e.preventDefault();
      const emailInput = document.getElementById('reset-email');
      const email = emailInput?.value.trim();
      
      if (email) {
        await this.handlePasswordReset(email);
      }
    });

    // Escape key to close
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && modal?.style.display !== 'none') {
        closeModal();
      }
    });
  }

  showPasswordResetModal() {
    const modal = document.getElementById('password-reset-modal');
    const emailInput = document.getElementById('reset-email');
    const form = document.getElementById('password-reset-form');
    const loading = document.getElementById('reset-loading');
    const success = document.getElementById('reset-success');

    // Reset modal state
    form.style.display = 'block';
    loading.style.display = 'none';
    success.style.display = 'none';

    // Pre-fill email from login form if available
    const loginEmailInput = document.getElementById('email');
    if (loginEmailInput?.value.trim()) {
      emailInput.value = loginEmailInput.value.trim();
    }

    // Show modal
    modal.style.display = 'block';
    emailInput?.focus();
  }

  hidePasswordResetModal() {
    const modal = document.getElementById('password-reset-modal');
    modal.style.display = 'none';
    
    // Reset form
    const form = document.getElementById('password-reset-form');
    const emailInput = document.getElementById('reset-email');
    if (form && emailInput) {
      form.reset();
    }
  }

  async handlePasswordReset(email) {
    const form = document.getElementById('password-reset-form');
    const loading = document.getElementById('reset-loading');
    const success = document.getElementById('reset-success');

    // Show loading state
    form.style.display = 'none';
    loading.style.display = 'block';

    try {
      const result = await window.AuthService.requestPasswordReset(email);
      
      // Hide loading
      loading.style.display = 'none';
      
      if (result.success) {
        // Show success state
        success.style.display = 'block';
        
        // Auto-close after 5 seconds
        setTimeout(() => {
          this.hidePasswordResetModal();
        }, 5000);
      } else {
        // Show error and return to form
        form.style.display = 'block';
        const emailInput = document.getElementById('reset-email');
        emailInput?.focus();
        
        // Show error notification if available
        if (window.showNotification) {
          window.showNotification(result.error || 'Failed to send password reset email', 'error');
        }
      }
    } catch (error) {
      console.error('Password reset error:', error);
      
      // Hide loading and show form
      loading.style.display = 'none';
      form.style.display = 'block';
      
      const emailInput = document.getElementById('reset-email');
      emailInput?.focus();
      
      const errorMessage = error.message || 'Failed to send password reset email';
      
      // Show error notification if available
      if (window.showNotification) {
        window.showNotification(errorMessage, 'error');
      }
    }
  }

  setupSignupLink() {
    const signupLink = document.getElementById('signup-link');
    
    if (!signupLink) return;

    signupLink.addEventListener('click', (e) => {
      e.preventDefault();
      window.location.href = '/register.html';
    });
  }

  async checkExistingAuth() {
    try {
      // Check if user is already authenticated
      const result = await window.AuthService.getCurrentUserWithProfile();
      
      // Handle SUPABASE_CLIENT_UNAVAILABLE error gracefully
      if (result && result.error === "SUPABASE_CLIENT_UNAVAILABLE") {
        console.warn('[login] Supabase client unavailable - showing non-blocking message');
        if (window.Notify) {
          window.Notify.warning('Connection issue - login features may be limited');
        }
        // Continue to render login page normally
        return;
      }
      
      if (result && result.user) {
        console.log('User already logged in, redirecting to dashboard...');
        window.location.href = '/app/home.html';
      } else {
        // Normal case: user not logged in, no action needed
        console.debug('[login] No active user session found');
      }
    } catch (error) {
      // Check if this is a normal "not logged in" case
      const isSessionMissing = error.message?.includes('Auth session missing') || 
                              error.message?.includes('No active session') ||
                              error.message?.includes('Not authenticated') ||
                              error.name === 'AuthSessionMissingError';
      
      if (isSessionMissing) {
        // Silent handling for missing session - normal case
        console.debug('[login] User not authenticated (no session)');
        return;
      }
      
      // Real error - show user-friendly message once
      console.error('[login] Error checking authentication status:', error.message);
      
      if (window.Notify) {
        const modalId = window.UI?.createModal?.({
          title: 'Connection Issue',
          body: `
            <div class="auth-error">
              <p>Unable to check authentication status. This may be a network issue.</p>
              <p><small>Error: ${error.message}</small></p>
            </div>
          `,
          footer: `
            <button class="btn btn-secondary" onclick="window.UI.closeAllModals()">Close</button>
            <button class="btn btn-primary" onclick="window.loginController.checkExistingAuth()">Retry</button>
          `
        });
        
        if (modalId && window.UI) {
          window.UI.openModal(modalId);
        } else {
          window.Notify.error('Unable to connect to authentication service');
        }
      }
    }
  }

  // Cleanup method
  destroy() {
    console.log('Login page cleanup');
  }
}

// Initialize login controller
window.loginController = new LoginController();

// Export for potential testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = LoginController;
}
