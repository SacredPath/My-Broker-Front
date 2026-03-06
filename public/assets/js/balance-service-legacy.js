/**
 * Balance Service adapted for user_balances table
 * Use this if you want to keep the existing user_balances table structure
 */

class BalanceServiceLegacy {
  constructor() {
    this.cache = new Map();
    this.cacheTimeout = 30000; // 30 seconds cache
    this.api = window.API || null;
    
    if (!this.api) {
      console.error('[BalanceService] API client not available');
      return;
    }
  }

  /**
   * Get user balances with caching (adapted for user_balances table)
   * @param {string} userId - User ID
   * @param {boolean} forceRefresh - Force cache refresh
   * @returns {Promise<Object>} User balances
   */
  async getUserBalances(userId, forceRefresh = false) {
    try {
      const cacheKey = `balances_${userId}`;
      const cached = this.cache.get(cacheKey);
      
      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && cached && (Date.now() - cached.timestamp < this.cacheTimeout)) {
        console.log('[BalanceService] Using cached balances');
        return cached.data;
      }

      console.log('[BalanceService] Fetching fresh balances from user_balances table');
      
      // Fetch from user_balances table (legacy structure)
      const { data, error } = await this.api.serviceClient
        .from('user_balances')
        .select('*')
        .eq('user_id', userId);

      if (error) {
        console.error('[BalanceService] Database error:', error);
        throw new Error(`Failed to fetch balances: ${error.message}`);
      }

      // Transform data to standard format
      const transformedBalances = this.transformLegacyBalanceData(data || []);
      
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
   * Transform legacy user_balances data to standard balance format
   * @param {Array} rawData - Raw data from user_balances table
   * @returns {Object} Transformed balance data
   */
  transformLegacyBalanceData(rawData) {
    const balances = {};
    
    rawData.forEach(record => {
      // Legacy table has 'amount' field, map it to 'available'
      // Set 'locked' to 0 since legacy table doesn't track it
      balances[record.currency] = {
        available: parseFloat(record.amount) || 0,
        locked: 0, // Legacy table doesn't track locked amounts
        total: parseFloat(record.amount) || 0,
        currency: record.currency,
        updated_at: record.updated_at
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
      const userId = await this.api.getCurrentUserId();
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
   * Update balance in cache after transaction (adapted for legacy table)
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
        available: newBalance.amount || newBalance.available, // Handle legacy field
        locked: 0, // Legacy table doesn't track locked
        total: newBalance.amount || newBalance.available,
        updated_at: new Date().toISOString()
      };
      
      // Recalculate total USD
      cached.data.total_usd = this.calculateTotalUSD(cached.data.balances);
      cached.data.last_updated = new Date().toISOString();
      
      console.log(`[BalanceService] Cache updated for ${currency} balance (legacy mode)`);
    }
  }

  /**
   * Update balance in database (adapted for legacy table)
   * @param {string} userId - User ID
   * @param {string} currency - Currency code
   * @param {number} newAmount - New amount
   * @returns {Promise<Object>} Updated balance
   */
  async updateBalance(userId, currency, newAmount) {
    try {
      console.log(`[BalanceService] Updating ${currency} balance to ${newAmount} (legacy table)`);
      
      // Update user_balances table
      const { data, error } = await this.api.serviceClient
        .from('user_balances')
        .upsert({
          user_id: userId,
          currency: currency,
          amount: newAmount,
          updated_at: new Date().toISOString()
        })
        .select()
        .single();

      if (error) {
        throw error;
      }

      // Update cache
      this.updateCacheAfterTransaction(userId, currency, { amount: newAmount });
      
      console.log(`[BalanceService] Balance updated successfully:`, data);
      return data;
      
    } catch (error) {
      console.error('[BalanceService] Failed to update balance:', error);
      throw error;
    }
  }
}

// Create singleton instance (overwrite the original if needed)
window.BalanceService = new BalanceServiceLegacy();

console.log('[BalanceService] Legacy balance service loaded (adapted for user_balances table)');
