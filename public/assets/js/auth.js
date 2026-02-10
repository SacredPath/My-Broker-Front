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

      console.log('Attempting signup with:', {
        email: email.toLowerCase().trim(),
        passwordLength: password.length,
        profileData
      });

      // Try with minimal user metadata first to isolate the issue
      const userMetadata = {
        display_name: profileData.displayName || ''
      };
      
      // Only add phone if it exists and is valid
      if (profileData.phone && profileData.phone.trim()) {
        userMetadata.phone = profileData.phone.trim();
      }

      console.log('User metadata to send:', userMetadata);

      const { data, error } = await client.auth.signUp({
        email: email.toLowerCase().trim(),
        password,
        options: {
          data: userMetadata
        }
      });

      console.log('Supabase signup response:', { data, error });

      if (error) {
        console.error('Supabase signup error with metadata:', error);
        console.error('Error object structure:', JSON.stringify(error, null, 2));
        
        // If it's a 500 error, try without metadata to isolate the issue
        const is500Error = error.status === 500 || 
                          error.message?.includes('500') || 
                          error.message?.includes('Internal Server Error');
        
        console.log('Is 500 error?', is500Error);
        
        if (is500Error) {
          console.log('Retrying signup without user metadata...');
          const { data: data2, error: error2 } = await client.auth.signUp({
            email: email.toLowerCase().trim(),
            password
          });
          
          if (error2) {
            console.error('Supabase signup error without metadata:', error2);
            throw this.handleAuthError(error2);
          }
          
          console.log('Signup successful without metadata:', data2);
          // Use data2 for the rest of the flow
          data.user = data2.user;
          data.session = data2.session;
        } else {
          console.log('Throwing handleAuthError for non-500 error');
          throw this.handleAuthError(error);
        }
      }

      // Create user profile in database
      if (data.user && !data.session) {
        // User created but email not confirmed (auto-confirm OFF)
        console.log('// Create user profile in database with correct schema mapping');
        const profileDataToSave = {
          email: data.user.email,
          display_name: profileData.displayName || '',
          phone: profileData.phone || '',
          country: profileData.country || '',
          // Map address fields to bio since address columns don't exist
          bio: `Address: ${profileData.address?.address_line1 || ''} ${profileData.address?.address_line2 || ''}, ${profileData.address?.city || ''}, ${profileData.address?.state || ''} ${profileData.address?.postal_code || ''}. Occupation: ${profileData.compliance?.occupation || 'Not provided'}. New to investing: ${profileData.compliance?.new_to_investing || 'Not provided'}. PEP: ${profileData.compliance?.pep || 'Not specified'}. Referral: ${profileData.referralCode || 'None'}`,
          email_verified: false // Default false, only set by Back Office
        };
        
        console.log('Final profile data to save:', profileDataToSave);
        
        const profileResult = await this.createUserProfile(data.user.id, profileDataToSave);
        console.log('Profile creation result:', profileResult);

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
      console.error('Error caught in catch block:', JSON.stringify(error, null, 2));
      
      // Use the enhanced error handling
      const userFriendlyError = this.handleAuthError(error);
      
      if (window.Notify) {
        window.Notify.error(userFriendlyError.message);
      }

      return { success: false, error: userFriendlyError };
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

      console.log('Saving profile to database for user:', userId);
      console.log('Profile data to insert:', profileData);

      const { data, error } = await client
        .from('profiles')
        .insert({
          user_id: userId,  // Fixed: use user_id instead of id for foreign key
          ...profileData
        })
        .select()
        .single();

      if (error) {
        console.error('Database insertion error:', error);
        throw error;
      }

      console.log('Profile successfully saved to database:', data);
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

  // Update last login timestamp (note: schema uses updated_at trigger instead)
  async updateLastLogin(userId) {
    try {
      await this.ensureInitialized();
      const client = await this.supabaseClient.getClient();

      // The profiles table has an updated_at trigger that automatically updates
      // We don't need to manually update last_login as it doesn't exist in the schema
      console.debug('[auth] last login tracked via updated_at trigger');
    } catch (error) {
      console.debug('[auth] failed to track last login:', error.message);
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
    console.log('=== HANDLE AUTH ERROR CALLED ===');
    console.error('Auth error details:', error);
    console.error('Error structure:', {
      status: error.status,
      message: error.message,
      error: error.error,
      errorStatus: error.error?.status,
      errorMessage: error.error?.message,
      keys: Object.keys(error)
    });
    
    // Check for 500 errors in multiple ways
    const is500Error = error.status === 500 || 
                      (error.error && error.error.status === 500) ||
                      error.message?.includes('500') || 
                      error.message?.includes('Internal Server Error') ||
                      (error.error && error.error.message?.includes('500')) ||
                      (error.error && error.error.message?.includes('Internal Server Error'));
    
    console.log('=== 500 ERROR CHECK RESULT ===');
    console.log('is500Error:', is500Error);
    console.log('error.status:', error.status);
    console.log('error.message:', error.message);
    
    if (is500Error) {
      console.error('500 Server Error detected - returning specific error message');
      return new Error('Server error during registration. Please try again in a few moments.');
    }
    
    // Handle HTTP status errors
    if (error.status || (error.error && error.error.status)) {
      const status = error.status || (error.error && error.error.status);
      const message = error.message || (error.error && error.error.message);
      console.error('HTTP Error Status:', status, 'Message:', message);
      
      switch (status) {
        case 400:
          return new Error('Invalid request. Please check your information and try again.');
        case 422:
          if (message?.includes('User already registered') || message?.includes('user_already_exists')) {
            return new Error('An account with this email already exists. Please try logging in or use a different email.');
          }
          return new Error('Invalid registration data. Please check your information and try again.');
        case 429:
          return new Error('Too many requests. Please wait a moment and try again.');
        default:
          return new Error(`Registration failed with error ${status}. Please try again.`);
      }
    }
    
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
        return new Error('Too many attempts. Please wait and try again.');
      }
      
      // Network/connection issues
      if (error.message.includes('NetworkError') ||
          error.message.includes('Failed to fetch') ||
          error.message.includes('CONNECTION_FAILED')) {
        return new Error('Connection failed. Please check your internet connection.');
      }
      
      // Database errors
      if (error.message.includes('duplicate key') ||
          error.message.includes('unique constraint') ||
          error.message.includes('already exists')) {
        return new Error('An account with this email already exists.');
      }
    }

    // Generic fallback - provide more debugging info
    console.log('=== FALLING BACK TO GENERIC ERROR ===');
    console.log('Original error that was not handled:', error);
    return new Error(`Registration failed. Please try again. (Debug: ${error.message || 'Unknown error'})`);
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
