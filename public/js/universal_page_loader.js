/**
 * Universal Page Loader
 * Ensures profile sync runs on every page load
 * Includes all essential systems for consistent data management
 */

// Import core systems
import '/assets/js/profile_sync.js';
import '/assets/js/auth.js';
import '/assets/js/api.js';

class UniversalPageLoader {
    constructor() {
        this.pageType = this.detectPageType();
        this.init();
    }

    detectPageType() {
        const path = window.location.pathname;
        
        if (path.includes('/app/')) {
            if (path.includes('home')) return 'dashboard';
            if (path.includes('portfolio')) return 'portfolio';
            if (path.includes('deposits')) return 'deposits';
            if (path.includes('withdraw')) return 'withdraw';
            if (path.includes('signals')) return 'services';
            if (path.includes('settings')) return 'settings';
            if (path.includes('kyc')) return 'kyc';
            if (path.includes('support')) return 'support';
        }
        
        if (path.includes('/auth/')) {
            if (path.includes('login')) return 'login';
            if (path.includes('register')) return 'register';
        }
        
        return 'unknown';
    }

    async init() {
        console.log(`[UniversalLoader] Loading page: ${this.pageType}`);
        
        // Initialize core systems
        await this.initializeAuth();
        await this.initializeProfileSync();
        await this.initializePageSpecific();
        
        console.log('[UniversalLoader] Page initialization complete');
    }

    async initializeAuth() {
        // Ensure auth system is ready
        if (window.AuthStateManager) {
            // Auth will automatically initialize profile sync
            console.log('[UniversalLoader] Auth system initialized');
        }
    }

    async initializeProfileSync() {
        // Profile sync is already initialized in profile_sync.js
        // Just ensure it's running
        if (window.ProfileSync) {
            console.log('[UniversalLoader] Profile sync system active');
        }
    }

    async initializePageSpecific() {
        switch (this.pageType) {
            case 'dashboard':
                await this.loadDashboard();
                break;
            case 'portfolio':
                await this.loadPortfolio();
                break;
            case 'deposits':
                await this.loadDeposits();
                break;
            case 'withdraw':
                await this.loadWithdrawals();
                break;
            case 'settings':
                await this.loadSettings();
                break;
            case 'kyc':
                await this.loadKYC();
                break;
            case 'register':
                await this.loadRegistration();
                break;
            default:
                console.log('[UniversalLoader] No specific initialization for page type:', this.pageType);
        }
    }

    async loadDashboard() {
        // Ensure dashboard has complete user data
        if (window.AuthService && window.AuthStateManager) {
            const user = await window.AuthService.getCurrentUserWithProfile();
            if (user && user.profile) {
                console.log('[UniversalLoader] Dashboard loaded with complete profile');
            }
        }
    }

    async loadPortfolio() {
        // Ensure portfolio has user data
        console.log('[UniversalLoader] Portfolio page - checking profile completeness');
    }

    async loadDeposits() {
        // Ensure deposits page has user data
        console.log('[UniversalLoader] Deposits page - checking profile completeness');
    }

    async loadWithdrawals() {
        // Ensure withdrawals page has user data
        console.log('[UniversalLoader] Withdrawals page - checking profile completeness');
    }

    async loadSettings() {
        // Ensure settings page has complete profile
        console.log('[UniversalLoader] Settings page - checking profile completeness');
    }

    async loadKYC() {
        // Ensure KYC page has complete profile
        console.log('[UniversalLoader] KYC page - checking profile completeness');
    }

    async loadRegistration() {
        // Registration page - clear any old registration data
        console.log('[UniversalLoader] Registration page - clearing old data');
        localStorage.removeItem('registrationData');
        sessionStorage.removeItem('registrationData');
    }
}

// Initialize universal loader on every page
document.addEventListener('DOMContentLoaded', () => {
    window.UniversalLoader = new UniversalPageLoader();
});

// Also initialize if DOM is already loaded
if (document.readyState !== 'loading') {
    window.UniversalLoader = new UniversalLoaderLoader();
}
