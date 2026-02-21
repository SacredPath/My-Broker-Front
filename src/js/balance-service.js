/**
 * Unified Balance Service
 * Single source of truth for all balance operations across the platform
 * Standardizes balance access and implements caching for consistency
 */

class BalanceService {
  constructor() {
    this.cache = new Map();
    this.cacheTimeout = 30000; // 30 seconds cache
    this.api = null;
    this.initPromise = this.init();
  }

  async init() {
    // Wait for API client to be available
    let attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait
    
    while (!window.API && attempts < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, 100));
      attempts++;
    }
    
    if (window.API) {
      this.api = window.API;
      console.log('[BalanceService] API client connected');
    } else {
      console.error('[BalanceService] API client not available after timeout');
    }
  }

  async ensureApi() {
    if (!this.api) {
      await this.initPromise;
      if (!this.api) {
        throw new Error('API client not available');
      }
    }
    return this.api;
  }

  /**
   * Get user balances with caching
   * @param {string} userId - User ID
   * @param {boolean} forceRefresh - Force cache refresh
   * @returns {Promise<Object>} User balances
   */
  async getUserBalances(userId, forceRefresh = false) {
    try {
      const api = await this.ensureApi();
      const cacheKey = `balances_${userId}`;
      const cached = this.cache.get(cacheKey);
      
      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && cached && (Date.now() - cached.timestamp < this.cacheTimeout)) {
        console.log('[BalanceService] Using cached balances');
        return cached.data;
      }

      console.log('[BalanceService] Fetching fresh balances from database');
      
      // Fetch from wallet_balances table (single source of truth)
      const { data, error } = await api.serviceClient
        .from('wallet_balances')
        .select('*')
        .eq('user_id', userId);

      if (error) {
        console.error('[BalanceService] Database error:', error);
        throw new Error(`Failed to fetch balances: ${error.message}`);
      }

      // Transform data to standard format
      const transformedBalances = this.transformBalanceData(data || []);
      
      // Cache the result
      this.cache.set(cacheKey, {
        data: transformedBalances,
        timestamp: Date.now()
      });

      console.log('[BalanceService] Balances loaded and cached:', transformedBalances);
      return transformedBalances;

    } catch (error) {
      console.error('[BalanceService] Error fetching balances:', error);
      
      // Return cached data if available, even if expired
      const cacheKey = `balances_${userId}`;
      const cached = this.cache.get(cacheKey);
      if (cached) {
        console.warn('[BalanceService] Using expired cache due to error');
        return cached.data;
      }
      
      // Return default structure if no cache available
      return this.getDefaultBalances();
    }
  }

  /**
   * Transform database data to standard balance format
   * @param {Array} rawData - Raw data from database
   * @returns {Object} Transformed balance data
   */
  transformBalanceData(rawData) {
    const balances = {};
    
    // Handle case where rawData is undefined or null
    if (!rawData || !Array.isArray(rawData)) {
      console.warn('[BalanceService] Invalid or missing balance data:', rawData);
      return {
        balances: {},
        total_usd: 0,
        last_updated: new Date().toISOString()
      };
    }
    
    rawData.forEach(record => {
      if (!record) return; // Skip null/undefined records
      
      balances[record.currency] = {
        available: parseFloat(record.available) || 0,
        locked: parseFloat(record.locked || record.frozen) || 0, // Handle both locked and frozen column names
        total: parseFloat(record.total) || (parseFloat(record.available) + parseFloat(record.locked || record.frozen)),
        currency: record.currency,
        updated_at: record.updated_at || record.created_at
      };
    });

    return {
      balances,
      total_usd: this.calculateTotalUSD(balances),
      last_updated: new Date().toISOString()
    };
  }

  /**
   * Calculate total USD value across all currencies
   * @param {Object} balances - Balance data
   * @returns {number} Total USD value
   */
  calculateTotalUSD(balances) {
    let total = 0;
    
    Object.values(balances).forEach(balance => {
      if (balance.currency === 'USD') {
        total += balance.total;
      } else if (balance.currency === 'USDT') {
        // USDT is pegged to USD 1:1
        total += balance.total;
      }
      // Add other currency conversions as needed
    });

    return total;
  }

  /**
   * Get default balance structure
   * @returns {Object} Default balances
   */
  getDefaultBalances() {
    return {
      balances: {
        USD: {
          available: 0,
          locked: 0,
          total: 0,
          currency: 'USD',
          updated_at: new Date().toISOString()
        },
        USDT: {
          available: 0,
          locked: 0,
          total: 0,
          currency: 'USDT',
          updated_at: new Date().toISOString()
        }
      },
      total_usd: 0,
      last_updated: new Date().toISOString()
    };
  }

  /**
   * Get balance for specific currency
   * @param {string} userId - User ID
   * @param {string} currency - Currency code
   * @returns {Promise<Object>} Currency balance
   */
  async getCurrencyBalance(userId, currency) {
    const balances = await this.getUserBalances(userId);
    return balances.balances[currency] || {
      available: 0,
      locked: 0,
      total: 0,
      currency: currency,
      updated_at: new Date().toISOString()
    };
  }

  /**
   * Check if user has sufficient available balance
   * @param {string} userId - User ID
   * @param {string} currency - Currency code
   * @param {number} amount - Required amount
   * @returns {Promise<boolean>} Has sufficient balance
   */
  async hasSufficientBalance(userId, currency, amount) {
    const balance = await this.getCurrencyBalance(userId, currency);
    return balance.available >= amount;
  }

  /**
   * Invalidate cache for specific user
   * @param {string} userId - User ID
   */
  invalidateCache(userId) {
    const cacheKey = `balances_${userId}`;
    this.cache.delete(cacheKey);
    console.log(`[BalanceService] Cache invalidated for user ${userId}`);
  }

  /**
   * Clear all cache
   */
  clearAllCache() {
    this.cache.clear();
    console.log('[BalanceService] All cache cleared');
  }

  /**
   * Get cache statistics
   * @returns {Object} Cache stats
   */
  getCacheStats() {
    const now = Date.now();
    let validEntries = 0;
    let expiredEntries = 0;

    this.cache.forEach((value, key) => {
      if (now - value.timestamp < this.cacheTimeout) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    });

    return {
      totalEntries: this.cache.size,
      validEntries,
      expiredEntries,
      cacheTimeout: this.cacheTimeout
    };
  }

  /**
   * Preload balances for current user
   * @returns {Promise<Object>} Current user balances
   */
  async preloadCurrentUserBalances() {
    try {
      const api = await this.ensureApi();
      const userId = await api.getCurrentUserId();
      if (!userId) {
        throw new Error('User not authenticated');
      }
      
      return await this.getUserBalances(userId);
    } catch (error) {
      console.error('[BalanceService] Failed to preload current user balances:', error);
      return this.getDefaultBalances();
    }
  }

  /**
   * Update balance in cache after transaction
   * @param {string} userId - User ID
   * @param {string} currency - Currency code
   * @param {Object} newBalance - New balance data
   */
  updateCacheAfterTransaction(userId, currency, newBalance) {
    const cacheKey = `balances_${userId}`;
    const cached = this.cache.get(cacheKey);
    
    if (cached) {
      cached.data.balances[currency] = {
        ...cached.data.balances[currency],
        ...newBalance,
        updated_at: new Date().toISOString()
      };
      
      // Recalculate total USD
      cached.data.total_usd = this.calculateTotalUSD(cached.data.balances);
      cached.data.last_updated = new Date().toISOString();
      
      console.log(`[BalanceService] Cache updated for ${currency} balance`);
    }
  }
}

// Create singleton instance
window.BalanceService = new BalanceService();

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
  module.exports = BalanceService;
}

console.log('[BalanceService] Unified balance service loaded');
