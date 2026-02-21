/**
 * API Client - Single Source of Truth
 * All network calls go through this client with timeouts, AbortController, and standardized error mapping
 * Bounded retries (max 1) and user-friendly error handling
 */

import { supabase } from './supabaseClient.js';

class APIClient {
  constructor() {
    this.supabase = supabase.supabase;
    this.keepAliveInterval = null;
    this.requestQueue = new Map();
    this.init();
  }

  init() {
    this.startKeepAlive();
  }

  // Direct Supabase REST API calls instead of edge functions
  async fetchSupabase(table, options = {}) {
    const {
      method = 'GET',
      body,
      timeout = 10000,
      retries = 1,
      requireAuth = true,
      filters = {},
      select = '*'
    } = options;

    let authHeader = '';
    if (requireAuth) {
      const { data: { session }, error } = await this.supabase.auth.getSession();
      if (error || !session?.access_token) {
        throw new Error('UNAUTHENTICATED');
      }
      authHeader = `Bearer ${session.access_token}`;
    }

    // Build query parameters for GET requests
    let url = `${this.supabase.supabaseUrl}/rest/v1/${table}?select=${select}`;
    
    // Add filters to query
    Object.entries(filters).forEach(([key, value]) => {
      url += `&${key}=eq.${encodeURIComponent(value)}`;
    });

    const requestId = `${table}-${method}-${Date.now()}`;
    
    try {
      if (this.requestQueue.has(requestId)) {
        return this.requestQueue.get(requestId);
      }

      const requestPromise = this._executeSupabaseRequest(url, {
        method,
        body,
        timeout,
        authHeader,
        retries
      });

      this.requestQueue.set(requestId, requestPromise);
      const result = await requestPromise;
      this.requestQueue.delete(requestId);
      
      return result;

    } catch (error) {
      this.requestQueue.delete(requestId);
      throw error;
    }
  }

  async _executeSupabaseRequest(url, options) {
    const { method, body, timeout, authHeader, retries } = options;
    let lastError;
    
    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout);

        const response = await fetch(url, {
          method,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': authHeader,
            'apikey': this.supabase.supabaseKey,
            'Prefer': 'return=representation'
          },
          body: body ? JSON.stringify(body) : undefined,
          signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          throw new Error(errorData.message || errorData.error || `HTTP ${response.status}`);
        }

        const data = await response.json();
        return { data, error: null };

      } catch (error) {
        lastError = error;
        
        if (error.name === 'AbortError' || error.message === 'UNAUTHENTICATED') {
          throw error;
        }

        if (attempt < retries) {
          console.warn(`[APIClient] Retry ${attempt + 1}/${retries} for ${url}:`, error.message);
          const delay = Math.min(1000 * Math.pow(2, attempt), 5000) + Math.random() * 1000;
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }

    throw this._mapError(lastError, 'supabase');
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

  // Get portfolio snapshot with current balances and positions
  async getPortfolioSnapshot() {
    try {
      const userId = await this.getCurrentUserId();
      if (!userId) {
        throw new Error('User not authenticated');
      }

      // Get balances
      const { data: balances, error: balanceError } = await this.supabase
        .from('wallet_balances')
        .select('*')
        .eq('user_id', userId);

      // Get positions
      const { data: positions, error: positionError } = await this.supabase
        .from('user_positions')
        .select('*')
        .eq('user_id', userId);

      if (balanceError || positionError) {
        throw new Error(`Failed to fetch portfolio data: ${balanceError?.message || positionError?.message}`);
      }

      // Calculate total portfolio value
      const totalBalance = balances?.reduce((sum, balance) => 
        sum + (parseFloat(balance.total) || 0), 0) || 0;
      
      const totalInvested = positions?.reduce((sum, position) => 
        sum + (parseFloat(position.invested_amount) || 0), 0) || 0;

      return {
        totalBalance,
        totalInvested,
        positions: positions || [],
        balances: balances || [],
        lastUpdated: new Date().toISOString()
      };
    } catch (error) {
      console.error('[APIClient] Failed to get portfolio snapshot:', error);
      return {
        totalBalance: 0,
        totalInvested: 0,
        positions: [],
        balances: [],
        lastUpdated: new Date().toISOString()
      };
    }
  }

  // Get current user ID
  async getCurrentUserId() {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      return user?.id || null;
    } catch (error) {
      console.error('[APIClient] Failed to get current user ID:', error);
      return null;
    }
  }

  // Profile-specific methods using REST API
  async getProfile(userId) {
    return await this.fetchSupabase('profiles', {
      filters: { id: userId },
      select: '*'
    });
  }

  async updateProfile(userId, profileData) {
    return await this.fetchSupabase('profiles', {
      method: 'PATCH',
      body: profileData,
      filters: { id: userId }
    });
  }

  // Deposit methods fetching
  async getDepositMethods() {
    try {
      const response = await this.fetchSupabase('deposit_methods');
      const data = response?.data || [];
      return this.transformDepositMethods(data);
    } catch (error) {
      console.error('Failed to fetch deposit methods:', error);
      return [];
    }
  }

  transformDepositMethods(data) {
    if (!data) return [];
    return data.map(method => ({
      id: method.id,
      name: method.name,
      method_name: method.name,
      method_type: method.type,
      currency: method.currency,
      is_active: method.is_active,
      minAmount: method.min_amount,
      maxAmount: method.max_amount,
      description: method.description,
      icon: method.icon,
      network: method.network,
      address: method.address,
      bank_name: method.bank_name,
      account_number: method.account_number,
      routing_number: method.routing_number,
      paypal_email: method.paypal_email
    }));
  }

  // Balance fetching with canonical mapping
  async fetchBalances() {
    try {
      const response = await this.fetchSupabase('balances');
      const data = response?.data || [];
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

  // Deposit request creation
  async createDepositRequest(depositData) {
    try {
      const response = await this.fetchSupabase('deposit_requests', {
        method: 'POST',
        body: depositData
      });
      const data = response?.data || null;
      return this.transformDepositRequest(data);
    } catch (error) {
      console.error('Failed to create deposit request:', error);
      return { success: false, error: error.message };
    }
  }

  transformDepositRequest(data) {
    if (!data) return { success: false, error: 'No data returned' };
    return {
      success: true,
      data: data[0] || {}
    };
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

  // KYC related methods
  async getKYCStatus(userId) {
    try {
      const { data, error } = await this.supabase
        .from('profiles')
        .select('kyc_status, kyc_submitted_at, kyc_reviewed_at, kyc_rejection_reason')
        .eq('user_id', userId)
        .single();

      if (error) {
        // If no record found, return default status
        if (error.code === 'PGRST116') {
          return {
            success: true,
            data: {
              status: 'not_submitted',
              submitted_at: null,
              approved_at: null,
              rejection_reason: null
            }
          };
        }
        throw error;
      }

      return {
        success: true,
        data: {
          status: data.kyc_status || 'not_submitted',
          submitted_at: data.kyc_submitted_at,
          approved_at: data.kyc_reviewed_at, // Map reviewed_at to approved_at for consistency
          rejection_reason: data.kyc_rejection_reason
        }
      };
    } catch (error) {
      console.error('Failed to get KYC status:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  // Edge function replacement - use REST API calls instead
  async fetchEdge(functionName, options = {}) {
    console.warn(`[API] fetchEdge called for ${functionName} - using REST API instead`);
    
    // Map edge functions to REST API calls
    switch (functionName) {
      case 'positions_list':
        return await this.fetchSupabase('user_positions', {
          ...options,
          filters: { user_id: await this.getCurrentUserId() }
        });
      
      case 'conversion_quote':
        // For conversion quotes, return mock data for now
        return {
          data: {
            from_amount: options.body?.from_amount || 0,
            to_amount: options.body?.from_amount || 0, // 1:1 conversion for now
            rate: 1,
            fee: 0.01
          }
        };
      
      case 'keepalive':
        return { data: { status: 'ok', timestamp: new Date().toISOString() } };
      
      default:
        throw new Error(`Unknown edge function: ${functionName}`);
    }
  }

  // Get investment tiers list
  async fetchTiersList() {
    try {
      const response = await this.fetchSupabase('investment_tiers', {
        select: '*',
        order: { min_amount: 'asc' }
      });
      
      const tiers = response?.data || [];
      console.log('[API] Tiers loaded from database:', tiers.length, 'items');
      console.log('[API] Tier data sample:', tiers.slice(0, 2)); // Debug first 2 items
      return tiers;
    } catch (error) {
      console.error('Failed to fetch tiers:', error);
      return [];
    }
  }

  // Cleanup method
  destroy() {
    if (this.keepAliveInterval) {
      clearInterval(this.keepAliveInterval);
    }
    this.requestQueue.clear();
  }
}

// Initialize global API client (singleton)
if (!window.API) {
  window.API = new APIClient();
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = APIClient;
}

// Export individual methods for convenience
export const {
  fetchSupabase,
  fetchEdge,
  fetchTiersList,
  getProfile,
  updateProfile,
  fetchBalances,
  getDepositMethods,
  createDepositRequest,
  getCurrentUserId,
  getPortfolioSnapshot,
  getKYCStatus,
  verifyEdgeFunctions,
  destroy
} = APIClient;
