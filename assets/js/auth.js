/**
 * Authentication System
 * loginWithEmailPassword, loginWithGoogle, logout
 * registerWithEmailPassword + profile upsert
 * Enforces email auto-confirm OFF: shows "Check your email" message after signup
 */

class AuthService {
  constructor() {
    this.supabaseClient = window.SupabaseClient;
    this.initialized = false;
    this.init();
  }

  async init() {
    // Wait for Supabase client to be ready
    if (this.supabaseClient) {
      await this.supabaseClient.init();
      this.initialized = true;
    }
  }

  // Ensure Supabase client is ready
  async ensureInitialized() {
    if (!this.initialized) {
      await this.init();
    }
    return this.supabaseClient;
  }

  // Login with email and password
  async loginWithEmailPassword(email, password) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      // Defensive validation (in addition to controller validation)
      if (!email || typeof email !== 'string') {
        throw new Error('Email is required');
      }
      
      if (!password || typeof password !== 'string') {
        throw new Error('Password is required');
      }

      const normalizedEmail = email.trim().toLowerCase();
      if (!normalizedEmail || !normalizedEmail.includes('@')) {
        throw new Error('Valid email is required');
      }

      if (password.length === 0) {
        throw new Error('Password is required');
      }

      const { data, error } = await client.auth.signInWithPassword({
        email: normalizedEmail,
        password
      });

      if (error) {
        // Safe error diagnostics
        console.debug('[auth] signInWithPassword failed', {
          status: error?.status ?? null,
          code: error?.code ?? null,
          message: error?.message ?? String(error),
          isAuthError: error?.__isAuthError ?? false
        });
        throw this.handleAuthError(error);
      }

      // Update last login timestamp in profile
      if (data.user) {
        await this.updateLastLogin(data.user.id);
      }

      // Clear any stored intended destination
      sessionStorage.removeItem('intendedDestination');

      if (window.Notify) {
        window.Notify.success('Welcome back!');
      }

      // Redirect to dashboard after successful login
      setTimeout(() => {
        window.location.href = '/app/home.html';
      }, 1000);

      return { success: true, data };
    } catch (error) {
      console.error('Login failed:', error);
      
      if (window.Notify) {
        window.Notify.error(error.message || 'Login failed');
      }

      return { success: false, error };
    }
  }

  // Login with Google OAuth
  async loginWithGoogle() {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      const { data, error } = await client.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/auth/callback.html`,
          queryParams: {
            access_type: 'offline',
            prompt: 'consent'
          }
        }
      });

      if (error) {
        throw this.handleAuthError(error);
      }

      return { success: true, data };
    } catch (error) {
      console.error('Google login failed:', error);
      
      if (window.Notify) {
        window.Notify.error(error.message || 'Google login failed');
      }

      return { success: false, error };
    }
  }

  // Register new user with email and password
  async registerWithEmailPassword(email, password, profileData = {}) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      // Validate email
      try {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
          throw new Error('Please enter a valid email address');
        }
      } catch (error) {
        if (error.message.includes('valid email')) {
          throw error;
        }
        console.error('Email validation regex error:', error);
        throw new Error('Email validation failed');
      }

      // Validate password
      if (password.length < 8) {
        throw new Error('Password must be at least 8 characters long');
      }

      const { data, error } = await client.auth.signUp({
        email: email.toLowerCase().trim(),
        password,
        options: {
          data: {
            display_name: profileData.displayName || '',
            phone: profileData.phone || ''
          }
        }
      });

      if (error) {
        throw this.handleAuthError(error);
      }

      // Create user profile in database
      if (data.user && !data.session) {
        // User created but email not confirmed (auto-confirm OFF)
        await this.createUserProfile(data.user.id, {
          email: data.user.email,
          display_name: profileData.displayName || '',
          phone: profileData.phone || '',
          email_verified: false, // Default false, only set by Back Office
          role: 'user',
          created_at: new Date().toISOString()
        });

        // Show success message and redirect to login (rule B - no email verification required)
        if (window.Notify) {
          window.Notify.success('Account created successfully! You can now log in.');
        }

        // Redirect to login after short delay
        setTimeout(() => {
          window.location.href = '/login.html';
        }, 2000);

        return { success: true, data, redirectToLogin: true };
      }

      if (window.Notify) {
        window.Notify.success('Account created successfully!');
      }

      return { success: true, data };
    } catch (error) {
      console.error('Registration failed:', error);
      
      if (window.Notify) {
        window.Notify.error(error.message || 'Registration failed');
      }

      return { success: false, error };
    }
  }

  // Logout user
  async logout() {
    try {
      await this.ensureInitialized();
      
      const success = await this.supabaseClient.signOut();
      
      if (!success) {
        throw new Error('Failed to sign out');
      }

      // Clear any local storage data
      localStorage.removeItem('supabase.auth.token');
      sessionStorage.clear();

      if (window.Notify) {
        window.Notify.success('Signed out successfully');
      }

      // Redirect to home page
      setTimeout(() => {
        window.location.href = '/index.html';
      }, 1000);

      return { success: true };
    } catch (error) {
      console.error('Logout failed:', error);
      
      if (window.Notify) {
        window.Notify.error(error.message || 'Logout failed');
      }

      return { success: false, error };
    }
  }

  // Create user profile in database
  async createUserProfile(userId, profileData) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      const { data, error } = await client
        .from('profiles')
        .insert({
          id: userId,
          ...profileData
        })
        .select()
        .single();

      if (error) {
        throw error;
      }

      return { success: true, data };
    } catch (error) {
      console.error('Failed to create user profile:', error);
      // Don't throw error here to prevent blocking signup
      return { success: false, error };
    }
  }

  // Update user profile
  async updateUserProfile(userId, profileData) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      // Remove sensitive fields that shouldn't be updated directly
      const { user_id, email_verified, role, created_at, ...safeProfileData } = profileData;

      const { data, error } = await client
        .from('profiles')
        .update(safeProfileData)
        .eq('user_id', userId)
        .select()
        .single();

      if (error) {
        throw error;
      }

      if (window.Notify) {
        window.Notify.success('Profile updated successfully');
      }

      return { success: true, data };
    } catch (error) {
      console.error('Failed to update user profile:', error);
      
      if (window.Notify) {
        window.Notify.error(error.message || 'Failed to update profile');
      }

      return { success: false, error };
    }
  }

  // Get user profile
  async getUserProfile(userId) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      const { data, error } = await client
        .from('profiles')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle();

      if (error) {
        console.debug('[auth] profile query error:', error.status, error.message);
        throw error;
      }

      // Handle missing profile gracefully
      if (!data) {
        console.debug('[auth] no profile found for user:', userId);
        return { success: true, data: null };
      }

      return { success: true, data };
    } catch (error) {
      // Handle missing session gracefully
      if (error.message?.includes('Auth session missing') || 
          error.message?.includes('No active session') ||
          error.message?.includes('Not authenticated')) {
        console.debug('[auth] user not authenticated, returning null profile');
        return { success: true, data: null };
      }

      console.debug('[auth] failed to get user profile:', error.status, error.message);
      return { success: false, error };
    }
  }

  // Update last login timestamp
  async updateLastLogin(userId) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      const { error } = await client
        .from('profiles')
        .update({ last_login: new Date().toISOString() })
        .eq('user_id', userId);

      if (error) {
        console.debug('[auth] failed to update last login:', error.status, error.message);
      } else {
        console.debug('[auth] last login updated successfully');
      }
    } catch (error) {
      console.debug('[auth] failed to update last login:', error.message);
    }
  }

  // Resend verification email
  async resendVerificationEmail(email) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      const { data, error } = await client.auth.resend({
        type: 'signup',
        email: email.toLowerCase().trim()
      });

      if (error) {
        throw error;
      }

      if (window.Notify) {
        window.Notify.success('Verification email resent');
      }

      return { success: true, data };
    } catch (error) {
      console.error('Failed to resend verification email:', error);
      
      if (window.Notify) {
        window.Notify.error(error.message || 'Failed to resend verification email');
      }

      return { success: false, error };
    }
  }

  // Reset password
  async resetPassword(email) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      const { data, error } = await client.auth.resetPasswordForEmail(
        email.toLowerCase().trim(),
        {
          redirectTo: `${window.location.origin}/login.html`
        }
      );

      if (error) {
        throw error;
      }

      if (window.Notify) {
        window.Notify.success('Password reset email sent');
      }

      return { success: true, data };
    } catch (error) {
      console.error('Failed to send password reset email:', error);
      
      if (window.Notify) {
        window.Notify.error(error.message || 'Failed to send password reset email');
      }

      throw error;
    }
  }

  // Request password reset (alias for resetPassword)
  async requestPasswordReset(email) {
    return this.resetPassword(email);
  }

  // Handle auth errors and provide user-friendly messages
  handleAuthError(error) {
    // ...
    if (error.message) {
      // Email not confirmed errors - treat as generic login failure (rule B)
      if (error.message.includes('Email not confirmed') || 
          error.message.includes('email_not_confirmed') ||
          error.message.includes('Email confirmation required')) {
        console.debug('[auth] Email confirmation error treated as generic login failure');
        return new Error('Login failed. Contact support.');
      }
      
      // Invalid credentials
      if (error.message.includes('Invalid login credentials') ||
          error.message.includes('invalid_credentials') ||
          error.message.includes('Invalid email or password')) {
        return new Error('Invalid email or password.');
      }
      
      // User not found
      if (error.message.includes('User not found') ||
          error.message.includes('user_not_found')) {
        return new Error('Invalid email or password.');
      }
      
      // Rate limiting
      if (error.message.includes('Too many requests') ||
          error.message.includes('rate_limit') ||
          error.message.includes('Too many login attempts')) {
        return new Error('Too many login attempts. Please wait a moment and try again.');
      }
      
      // Network/connection issues
      if (error.message.includes('NetworkError') ||
          error.message.includes('Failed to fetch') ||
          error.message.includes('CONNECTION_FAILED')) {
        return new Error('Connection failed. Please check your internet connection and try again.');
      }
    }

    // Generic fallback
    return new Error('Login failed. Please try again.');
  }

  // Check if user is authenticated
  async isAuthenticated() {
    try {
      const session = await this.supabaseClient.getSession();
      return !!session;
    } catch (error) {
      console.error('Error checking authentication status:', error);
      return false;
    }
  }

  // Get current user with profile
  async getCurrentUserWithProfile() {
    try {
      await this.ensureInitialized();
      const user = await this.supabaseClient.getCurrentUser();
      
      if (!user) {
        return null;
      }

      const profileResult = await this.getUserProfile(user.id);
      
      return {
        ...user,
        profile: profileResult.success ? profileResult.data : null
      };
    } catch (error) {
      console.error('Error getting current user with profile:', error);
      return null;
    }
  }

  // Handle OAuth callback
  async handleAuthCallback() {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      const { data, error } = await client.auth.getSession();
      
      if (error) {
        throw error;
      }

      if (data.session) {
        // Update last login
        await this.updateLastLogin(data.session.user.id);
        
        // Redirect to intended destination or dashboard
        const intendedDestination = sessionStorage.getItem('intendedDestination') || '/app/home.html';
        sessionStorage.removeItem('intendedDestination');
        
        window.location.href = intendedDestination;
      }

      return { success: true, data };
    } catch (error) {
      console.error('Error handling auth callback:', error);
      
      if (window.Notify) {
        window.Notify.error('Authentication failed');
      }

      return { success: false, error };
    }
  }
}

// Create and export singleton instance
const authService = new AuthService();

// Export for global access
window.AuthService = authService;

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = authService;
}

// Export individual methods for convenience
export const {
  loginWithEmailPassword,
  loginWithGoogle,
  logout,
  registerWithEmailPassword,
  createUserProfile,
  updateUserProfile,
  getUserProfile,
  resendVerificationEmail,
  resetPassword,
  requestPasswordReset,
  isAuthenticated,
  getCurrentUserWithProfile,
  handleAuthCallback
} = authService;
