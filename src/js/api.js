/**
 * API Client - Single Source of Truth
 * All network calls go through this client with timeouts, AbortController, and standardized error mapping
 * Bounded retries (max 1) and user-friendly error handling
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

class APIClient {
  constructor() {
    this.supabase = null;
    this.keepAliveInterval = null;
    this.requestQueue = new Map();
    this.init();
  }

  init() {
    this.initSupabase();
    this.startKeepAlive();
  }

  initSupabase() {
    try {
      const env = window.__ENV || {};
      const SUPABASE_URL = env.SUPABASE_URL || "https://ubycoeyutauzjgxbozcm.supabase.co";
      const SUPABASE_ANON_KEY = env.SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVieWNvZXl1dGF1empneGJvemNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0MDYyOTIsImV4cCI6MjA4NDk4MjI5Mn0.NUqdlArOGnCUEXuQYummEgsJKHoTk3fUvBarKIagHMM";
      
      this.supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
      console.log('[APIClient] Initialized');
    } catch (error) {
      console.error('[APIClient] Init failed:', error);
    }
  }

  // Core Edge Function fetch with timeout, abort, and 1 retry
  async fetchEdge(functionName, options = {}) {
    const {
      method = 'GET',
      body,
      timeout = 10000, // 10 second timeout
      retries = 1, // Max 1 retry as per requirements
      requireAuth = true
    } = options;

    const requestId = `${functionName}-${Date.now()}`;
    
    try {
      // Check if request is already in progress
      if (this.requestQueue.has(requestId)) {
        return this.requestQueue.get(requestId);
      }

      const requestPromise = this._executeRequest(functionName, {
        method,
        body,
        timeout,
        requireAuth,
        retries
      });

      this.requestQueue.set(requestId, requestPromise);

      const result = await requestPromise;
      
      // Clean up queue
      this.requestQueue.delete(requestId);
      
      return result;

    } catch (error) {
      this.requestQueue.delete(requestId);
      throw error;
    }
  }

  async _executeRequest(functionName, options) {
    const { method, body, timeout, requireAuth, retries } = options;
    
    let lastError;
    
    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        // Get auth session if required
        let authHeader = '';
        if (requireAuth) {
          const { data: { session }, error } = await this.supabase.auth.getSession();
          if (error || !session?.access_token) {
            throw new Error('UNAUTHENTICATED');
          }
          authHeader = `Bearer ${session.access_token}`;
        }

        // Create AbortController for timeout
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout);

        const edgeFunctionUrl = `${this.supabase.supabaseUrl}/functions/v1/${functionName}`;
        
        const response = await fetch(edgeFunctionUrl, {
          method,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': authHeader,
            ...options.headers
          },
          body: body ? JSON.stringify(body) : undefined,
          signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(errorData.error || `HTTP ${response.status}`);
        }

        const data = await response.json();
        
        // Validate response structure
        if (data.error) {
          throw new Error(data.error);
        }

        return { data: data.data || data, error: null };

      } catch (error) {
        lastError = error;
        
        // Don't retry on authentication errors or aborts
        if (error.name === 'AbortError' || error.message === 'UNAUTHENTICATED') {
          throw error;
        }

        // Log retry attempt
        if (attempt < retries) {
          console.warn(`[APIClient] Retry ${attempt + 1}/${retries} for ${functionName}:`, error.message);
          // Exponential backoff with jitter
          const delay = Math.min(1000 * Math.pow(2, attempt), 5000) + Math.random() * 1000;
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }

    // All retries failed - map to user-friendly error
    throw this._mapError(lastError, functionName);
  }

  // Error mapping for user-friendly messages
  _mapError(error, functionName) {
    const message = error.message || 'Unknown error';
    
    // Network errors
    if (error.name === 'AbortError') {
      return new Error('Request timed out. Please check your connection and try again.');
    }
    
    if (message.includes('fetch')) {
      return new Error('Network error. Please check your connection and try again.');
    }

    // Authentication errors
    if (message === 'UNAUTHENTICATED') {
      return new Error('Please log in to continue.');
    }

    // Server errors
    if (message.includes('500') || message.includes('SERVER_ERROR')) {
      return new Error('Server error. Please try again in a moment.');
    }

    // Permission errors
    if (message.includes('403') || message.includes('UNAUTHORIZED')) {
      return new Error('You do not have permission to perform this action.');
    }

    // Validation errors
    if (message.includes('400') || message.includes('INVALID')) {
      return new Error('Invalid request. Please check your input and try again.');
    }

    // Default error
    return new Error(`An error occurred: ${message}`);
  }

  // Keep-alive ping every 10 minutes
  startKeepAlive() {
    // Clear any existing interval
    if (this.keepAliveInterval) {
      clearInterval(this.keepAliveInterval);
    }

    // Set up keep-alive ping every 10 minutes
    this.keepAliveInterval = setInterval(async () => {
      try {
        await this.pingKeepAlive();
      } catch (error) {
        console.error('[APIClient] Keep-alive ping failed:', error);
      }
    }, 10 * 60 * 1000); // 10 minutes

    console.log('[APIClient] Keep-alive ping started (10-minute interval)');
  }

  async pingKeepAlive() {
    try {
      await this.fetchEdge('keepalive', {
        method: 'GET',
        timeout: 5000,
        requireAuth: false
      });
      console.log('[APIClient] Keep-alive ping successful');
    } catch (error) {
      console.warn('[APIClient] Keep-alive ping failed:', error.message);
    }
  }

  // Balance fetching with canonical mapping
  async fetchBalances() {
    try {
      const data = await this.fetchEdge('balances_get');
      return this.transformBalanceData(data);
    } catch (error) {
      console.error('Failed to fetch balances:', error);
      return [];
    }
  }

  transformBalanceData(data) {
    if (!data) return [];
    return data.map(item => ({
      symbol: item.symbol,
      amount: item.amount,
      value: item.usd_value || 0
    }));
  }

  // Verify Edge Functions are working
  async verifyEdgeFunctions() {
    const functions = ['balances_get', 'prices_get', 'user_profile_get'];
    const results = {};
    
    for (const func of functions) {
      try {
        await this.fetchEdge(func);
        results[func] = 'OK';
      } catch (error) {
        results[func] = error.message;
      }
    }
    
    return results;
  }

  // Cleanup method
  destroy() {
    if (this.keepAliveInterval) {
      clearInterval(this.keepAliveInterval);
    }
    this.requestQueue.clear();
  }
}

// Initialize global API client
window.API = new APIClient();

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = APIClient;
}
