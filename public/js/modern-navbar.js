// Modern Navbar JavaScript - Icon-Only Navigation with Working Dropdown
class ModernNavbar {
    constructor() {
        this.isOpen = false;
        this.notifications = [];
        this.currentPage = this.getCurrentPage();
        this.init();
    }

    init() {
        this.injectNavbar();
        this.setupEventListeners();
        this.updateActiveNavigation();
        this.setupThemeToggle();
        this.setupNotifications();
        this.setupUserDisplay();
    }

    injectNavbar() {
        const container = document.getElementById('modern-navbar-container');
        if (container) {
            container.innerHTML = this.getNavbarHTML();
        }
    }

    getNavbarHTML() {
        return `<!-- Modern Navigation Bar -->
<nav class="modern-navbar">
    <div class="navbar-wrapper">
        <!-- Left Section: Brand + Mobile Toggle -->
        <a href="/app/home.html" class="navbar-brand" style="text-decoration: none; color: inherit;">
            <button class="mobile-toggle" id="mobile-menu-toggle" aria-label="Toggle menu">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="3" y1="12" x2="21" y2="12"></line>
                    <line x1="3" y1="6" x2="21" y2="6"></line>
                    <line x1="3" y1="18" x2="21" y2="18"></line>
                </svg>
            </button>
            <div class="brand-logo">DOGE</div>
<h1 class="brand-text">DOGE INITIATIVE</h1>
        </a>

        <!-- Center Section: Icon Navigation -->
        <div class="navbar-center">
            <nav class="nav-menu">
                <a href="/app/home.html" class="nav-item" data-page="home" title="Home">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                        <polyline points="9 22 9 12 15 12 15 22"></polyline>
                    </svg>
                </a>
                <a href="/app/deposits.html" class="nav-item" data-page="deposits" title="Deposits">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="12" y1="5" x2="12" y2="19"></line>
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                    </svg>
                </a>
                <a href="/app/tiers.html" class="nav-item" data-page="tiers" title="Investment Strategies">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"/>
                    </svg>
                </a>
                <a href="/app/positions.html" class="nav-item" data-page="positions" title="Positions">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 3v18h18"/>
                        <path d="M18.7 8l-5.1 5.2-2.8-2.7L7 14.3"/>
                    </svg>
                </a>
                <a href="/app/signals.html" class="nav-item" data-page="signals" title="Signals">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                        <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                    </svg>
                </a>
                <a href="/app/settings.html" class="nav-item" data-page="settings" title="Settings">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="3"></circle>
                        <path d="M12 1v6m0 6v6m4.22-13.22l4.24 4.24M1.54 1.54l4.24 4.24M20.46 20.46l-4.24-4.24M1.54 20.46l4.24-4.24"></path>
                    </svg>
                </a>
            </nav>
        </div>

        <!-- Right Section: Actions -->
        <div class="navbar-right">
            <button class="nav-action" id="notification-btn" aria-label="Notifications">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                    <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                </svg>
                <span class="notification-indicator" id="notification-indicator"></span>
            </button>
            
            <button class="nav-action" id="theme-toggle" aria-label="Toggle theme">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="5"></circle>
                    <line x1="12" y1="1" x2="12" y2="3"></line>
                    <line x1="12" y1="21" x2="12" y2="23"></line>
                    <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                    <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                    <line x1="1" y1="12" x2="3" y2="12"></line>
                    <line x1="21" y1="12" x2="23" y2="12"></line>
                    <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                    <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                </svg>
            </button>
            
            <div class="user-dropdown" id="user-dropdown">
                <div class="user-menu" id="user-menu">
                    <div class="user-avatar" id="navbar-user-avatar">U</div>
                    <span class="user-name" id="navbar-user-name">Loading...</span>
                    <svg class="dropdown-arrow" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="6 9 12 15 18 9"></polyline>
                    </svg>
                </div>
                
                <!-- Dropdown Menu -->
                <div class="dropdown-menu" id="main-dropdown-menu">
                    <div class="dropdown-section">
                        <div class="dropdown-title">Account</div>
                        <a href="/app/profile.html" class="dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <span>Profile</span>
                        </a>
                        <a href="/app/kyc.html" class="dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M16 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="8.5" cy="7" r="4"></circle>
                                <line x1="20" y1="8" x2="20" y2="14"></line>
                                <line x1="23" y1="11" x2="17" y2="11"></line>
                            </svg>
                            <span>KYC Verification</span>
                        </a>
                    </div>
                    
                    <div class="dropdown-section">
                        <div class="dropdown-title">Investing</div>
                        <a href="/app/portfolio.html" class="dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <line x1="12" y1="1" x2="12" y2="23"></line>
                                <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                            </svg>
                            <span>Portfolio</span>
                        </a>
                        <a href="/app/history.html" class="dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M12 8v4l3 3m6-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"></path>
                            </svg>
                            <span>History</span>
                        </a>
                    </div>
                    
                    <div class="dropdown-divider"></div>
                    
                    <div class="dropdown-section">
                        <a href="/app/support.html" class="dropdown-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                            </svg>
                            <span>Support</span>
                        </a>
                        <button class="dropdown-item" id="navbar-logout-btn" data-action="logout" type="button">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                                <polyline points="16 17 21 17 21 7"></polyline>
                            </svg>
                            <span>Logout</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Notification Panel -->
<div id="notification-panel" class="notification-panel">
    <div class="notification-header">
        <h3>Notifications</h3>
        <button id="close-notifications" class="close-btn">×</button>
    </div>
    <div class="notification-list" id="notification-list">
        <!-- Notifications will be loaded here -->
    </div>
</div>

<!-- Mobile Navigation Menu -->
<div class="mobile-nav-menu" id="mobile-nav-menu">
    <div class="mobile-nav-content">
        <div class="mobile-nav-section">
            <div class="mobile-nav-title">Main</div>
            <a href="/app/home.html" class="mobile-nav-item" data-page="home">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                    <polyline points="9 22 9 12 15 12 15 22"></polyline>
                </svg>
                <span>Home</span>
            </a>
            <a href="/app/history.html" class="mobile-nav-item" data-page="history">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 8v4l3 3m6-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"></path>
                </svg>
                <span>History</span>
            </a>
        </div>
        
        <div class="mobile-nav-section">
            <div class="mobile-nav-title">Investing</div>
            <a href="/app/tiers.html" class="mobile-nav-item" data-page="tiers">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"/>
                </svg>
                <span>Strategies</span>
            </a>
            <a href="/app/deposits.html" class="mobile-nav-item" data-page="deposits">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                <span>Deposits</span>
            </a>
            <a href="/app/withdraw.html" class="mobile-nav-item" data-page="withdrawals">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                    <polyline points="12 19 19 12 12 5"></polyline>
                </svg>
                <span>Withdraw</span>
            </a>
            <a href="/app/convert.html" class="mobile-nav-item" data-page="convert">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="23 4 23 10 17 10"></polyline>
                    <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path>
                </svg>
                <span>Convert</span>
            </a>
            <a href="/app/signals.html" class="mobile-nav-item" data-page="signals">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                    <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                </svg>
                <span>Signals</span>
            </a>
        </div>
        
        <div class="mobile-nav-section">
            <div class="mobile-nav-title">Account</div>
            <a href="/app/settings.html" class="mobile-nav-item" data-page="settings">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="3"></circle>
                    <path d="M12 1v6m0 6v6m4.22-13.22l4.24 4.24M1.54 9.54l4.24 4.24M20.46 14.46l-4.24 4.24M7.76 7.76L3.52 3.52"></path>
                </svg>
                <span>Settings</span>
            </a>
            <a href="/app/support.html" class="mobile-nav-item" data-page="support">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
                <span>Support</span>
            </a>
        </div>
    </div>
</div>

<!-- Overlay -->
<div class="nav-overlay" id="nav-overlay"></div>`;
    }

    setupEventListeners() {
        // Mobile menu toggle
        const mobileToggle = document.getElementById('mobile-menu-toggle');
        const mobileMenu = document.getElementById('mobile-nav-menu');
        const overlay = document.getElementById('nav-overlay');

        if (mobileToggle && mobileMenu && overlay) {
            mobileToggle.addEventListener('click', () => this.toggleMobileMenu());
            
            // Close menu when clicking overlay
            overlay.addEventListener('click', () => this.closeMobileMenu());
            
            // Close menu on escape key
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && this.isOpen) {
                    this.closeMobileMenu();
                }
            });
        }

        // User dropdown
        const userDropdown = document.getElementById('user-dropdown');
        const userMenu = document.getElementById('user-menu');
        const dropdownMenu = document.getElementById('main-dropdown-menu');

        if (userDropdown && userMenu && dropdownMenu) {
            userMenu.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                this.toggleUserDropdown();
            });
            
            // Close dropdown when clicking outside
            document.addEventListener('click', (e) => {
                if (!userDropdown.contains(e.target) && !dropdownMenu.contains(e.target)) {
                    this.closeUserDropdown();
                }
            });
        }

        // Navigation item clicks
        const navItems = document.querySelectorAll('.nav-item, .mobile-nav-item, .dropdown-item');
        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                const page = e.currentTarget.dataset.page;
                if (page) {
                    this.setActivePage(page);
                }
                
                // Close mobile menu if open
                if (this.isOpen) {
                    this.closeMobileMenu();
                }
                
                // Close user dropdown
                this.closeUserDropdown();
            });
        });

        // Handle window resize
        window.addEventListener('resize', () => {
            if (window.innerWidth > 768 && this.isOpen) {
                this.closeMobileMenu();
            }
        });

        // Handle logout button click
        const logoutBtn = document.getElementById('navbar-logout-btn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', async (e) => {
                e.preventDefault();
                e.stopPropagation();
                
                try {
                    // Close dropdown
                    this.closeUserDropdown();
                    
                    // Perform logout
                    if (window.AuthService) {
                        await window.AuthService.logout();
                    }
                    
                    // Redirect to login
                    window.location.href = '/login.html';
                } catch (error) {
                    console.error('Logout failed:', error);
                    if (window.Notify) {
                        window.Notify.error('Logout failed');
                    }
                }
            });
        }
    }

    toggleMobileMenu() {
        const mobileMenu = document.getElementById('mobile-nav-menu');
        const overlay = document.getElementById('nav-overlay');
        
        if (this.isOpen) {
            this.closeMobileMenu();
        } else {
            this.openMobileMenu();
        }
    }

    openMobileMenu() {
        const mobileMenu = document.getElementById('mobile-nav-menu');
        const overlay = document.getElementById('nav-overlay');
        
        mobileMenu.classList.add('open');
        overlay.classList.add('open');
        document.body.style.overflow = 'hidden';
        this.isOpen = true;
    }

    closeMobileMenu() {
        const mobileMenu = document.getElementById('mobile-nav-menu');
        const overlay = document.getElementById('nav-overlay');
        
        mobileMenu.classList.remove('open');
        overlay.classList.remove('open');
        document.body.style.overflow = '';
        this.isOpen = false;
    }

    toggleUserDropdown() {
        const dropdownMenu = document.getElementById('main-dropdown-menu');
        if (dropdownMenu) {
            const isVisible = dropdownMenu.classList.contains('show');
            
            if (isVisible) {
                dropdownMenu.classList.remove('show');
                this.resetDropdownStyles(dropdownMenu);
            } else {
                dropdownMenu.classList.add('show');
                this.forceDropdownVisible(dropdownMenu);
            }
        }
    }

    forceDropdownVisible(dropdownMenu) {
        // Force visibility to override any CSS issues
        dropdownMenu.style.setProperty('opacity', '1', 'important');
        dropdownMenu.style.setProperty('visibility', 'visible', 'important');
        dropdownMenu.style.setProperty('transform', 'translateY(0)', 'important');
        dropdownMenu.style.setProperty('display', 'block', 'important');
    }

    resetDropdownStyles(dropdownMenu) {
        // Reset forced styles when hiding
        dropdownMenu.style.removeProperty('opacity');
        dropdownMenu.style.removeProperty('visibility');
        dropdownMenu.style.removeProperty('transform');
        dropdownMenu.style.removeProperty('display');
    }

    closeUserDropdown() {
        const dropdownMenu = document.getElementById('main-dropdown-menu');
        if (dropdownMenu) {
            dropdownMenu.classList.remove('show');
            this.resetDropdownStyles(dropdownMenu);
        }
    }

    getCurrentPage() {
        const path = window.location.pathname;
        const pageMap = {
            '/app/home.html': 'home',
            '/app/tiers.html': 'tiers',
            '/app/deposits.html': 'deposits',
            '/app/withdraw.html': 'withdrawals',
            '/app/convert.html': 'convert',
            '/app/signals.html': 'signals',
            '/app/portfolio.html': 'portfolio',
            '/app/history.html': 'history',
            '/app/settings.html': 'settings',
            '/app/support.html': 'support'
        };
        
        return pageMap[path] || 'home';
    }

    setActivePage(page) {
        // Remove active class from all items
        document.querySelectorAll('.nav-item, .mobile-nav-item, .dropdown-item').forEach(item => {
            item.classList.remove('active');
        });

        // Add active class to current page items
        document.querySelectorAll(`[data-page="${page}"]`).forEach(item => {
            item.classList.add('active');
        });

        this.currentPage = page;
    }

    updateActiveNavigation() {
        this.setActivePage(this.currentPage);
    }

    setupThemeToggle() {
        const themeToggle = document.getElementById('theme-toggle');
        if (themeToggle) {
            themeToggle.addEventListener('click', () => {
                const currentTheme = document.documentElement.getAttribute('data-theme');
                const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
                document.documentElement.setAttribute('data-theme', newTheme);
                localStorage.setItem('theme', newTheme);
            });
        }

        // Load saved theme
        const savedTheme = localStorage.getItem('theme') || 'dark';
        document.documentElement.setAttribute('data-theme', savedTheme);
    }

    setupNotifications() {
        const notificationBtn = document.getElementById('notification-btn');
        const notificationPanel = document.getElementById('notification-panel');
        const closeNotifications = document.getElementById('close-notifications');

        if (notificationBtn) {
            notificationBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                this.toggleNotificationPanel();
            });
        }

        if (closeNotifications) {
            closeNotifications.addEventListener('click', () => {
                this.closeNotificationPanel();
            });
        }

        // Close panel when clicking outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('#notification-btn') && !e.target.closest('.notification-panel')) {
                this.closeNotificationPanel();
            }
        });

        // Load initial notifications
        this.loadNotifications();
    }

    toggleNotificationPanel() {
        const notificationPanel = document.getElementById('notification-panel');
        if (notificationPanel) {
            const isOpen = notificationPanel.classList.contains('show');
            if (isOpen) {
                this.closeNotificationPanel();
            } else {
                this.openNotificationPanel();
            }
        }
    }

    openNotificationPanel() {
        const notificationPanel = document.getElementById('notification-panel');
        if (notificationPanel) {
            notificationPanel.classList.add('show');
            this.markNotificationsAsRead();
        }
    }

    closeNotificationPanel() {
        const notificationPanel = document.getElementById('notification-panel');
        if (notificationPanel) {
            notificationPanel.classList.remove('show');
        }
    }

    async loadNotifications() {
        try {
            if (!window.API) {
                console.warn('API not available, cannot load notifications');
                return;
            }
            
            const userId = await window.API.getCurrentUserId();
            if (!userId) {
                console.warn('User not authenticated, cannot load notifications');
                return;
            }

            const { data, error } = await window.API.supabase
                .from('notifications')
                .select('*')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(10);

            if (error) {
                console.error('Failed to load notifications:', error);
                this.notifications = [];
            } else {
                this.notifications = data || [];
            }
            
            this.updateNotificationBadge();
            this.renderNotifications();
        } catch (error) {
            console.error('Failed to load notifications:', error);
            this.notifications = [];
            this.updateNotificationBadge();
            this.renderNotifications();
        }
    }

    updateNotificationBadge() {
        const unreadCount = this.notifications.filter(n => n.unread).length;
        const indicator = document.getElementById('notification-indicator');
        
        if (indicator) {
            if (unreadCount > 0) {
                indicator.style.display = 'block';
                indicator.textContent = unreadCount > 9 ? '9+' : unreadCount;
            } else {
                indicator.style.display = 'none';
            }
        }
    }

    renderNotifications() {
        const notificationList = document.getElementById('notification-list');
        
        if (!notificationList) return;

        if (this.notifications.length === 0) {
            notificationList.innerHTML = `
                <div style="text-align: center; padding: 40px 20px; color: var(--text-secondary);">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin: 0 auto 16px; opacity: 0.5;">
                        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                        <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                    </svg>
                    <p>No notifications</p>
                </div>
            `;
            return;
        }

        notificationList.innerHTML = this.notifications.map(notification => `
            <div class="notification-item ${notification.unread ? 'unread' : ''}" data-id="${notification.id}">
                <div class="notification-header-info">
                    <div>
                        <div class="notification-title">${notification.title}</div>
                        <div class="notification-message">${notification.message}</div>
                    </div>
                    <div class="notification-time">${notification.time || 'Just now'}</div>
                </div>
            </div>
        `).join('');
    }

    markNotificationsAsRead() {
        this.notifications.forEach(notification => {
            notification.unread = false;
        });
        this.updateNotificationBadge();
        this.renderNotifications();
    }

    // Public methods for other components to use
    addNotification(notification) {
        if (!this.notifications) this.notifications = [];
        
        this.notifications.unshift({
            ...notification,
            id: Date.now(),
            time: 'Just now',
            unread: true
        });
        
        this.updateNotificationBadge();
        this.renderNotifications();
    }

    showNotification() {
        this.showNotificationIndicator();
    }

    hideNotifications() {
        this.clearNotificationIndicator();
    }

    showNotificationIndicator() {
        const indicator = document.getElementById('notification-indicator');
        if (indicator) {
            indicator.style.display = 'block';
        }
    }

    clearNotificationIndicator() {
        const indicator = document.getElementById('notification-indicator');
        if (indicator) {
            indicator.style.display = 'none';
        }
    }

    // User display functionality
    async setupUserDisplay() {
        // Load initial user data
        await this.updateUserDisplay();
        
        // Listen for auth state changes
        if (window.AuthStateManager) {
            window.AuthStateManager.addListener(async (event, session) => {
                if (event === 'SIGNED_IN' && session?.user) {
                    await this.updateUserDisplay();
                } else if (event === 'SIGNED_OUT') {
                    this.clearUserDisplay();
                }
            }, { id: 'modernNavbar' });
        }
    }

    async updateUserDisplay() {
        try {
            // Get current user with profile
            let user = null;
            
            // Try different auth service methods
            if (window.AuthService && window.AuthService.getCurrentUserWithProfile) {
                user = await window.AuthService.getCurrentUserWithProfile();
            } else if (window.AuthStateManager && window.AuthStateManager.getCurrentUser) {
                const currentUser = window.AuthStateManager.getCurrentUser();
                if (currentUser) {
                    user = {
                        ...currentUser,
                        profile: null // Will be populated if we can fetch it
                    };
                }
            } else {
                this.clearUserDisplay();
                return;
            }

            if (!user) {
                this.clearUserDisplay();
                return;
            }

            // Get display name from profile or email
            const displayName = user.profile?.display_name || 
                              user.email?.split('@')[0] || 
                              'User';

            // Update navbar elements
            const userAvatar = document.getElementById('navbar-user-avatar');
            const userName = document.getElementById('navbar-user-name');
            
            if (userAvatar) {
                userAvatar.textContent = displayName.charAt(0).toUpperCase();
            }
            
            if (userName) {
                userName.textContent = displayName;
            }

        } catch (error) {
            console.error('Error updating user display:', error);
            this.clearUserDisplay();
        }
    }

    clearUserDisplay() {
        const userAvatar = document.getElementById('navbar-user-avatar');
        const userName = document.getElementById('navbar-user-name');
        
        if (userAvatar) {
            userAvatar.textContent = 'U';
        }
        
        if (userName) {
            userName.textContent = 'Guest';
        }
    }
}

// Initialize navbar when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.modernNavbar = new ModernNavbar();
    
    // Wait for auth services to be available, then update user display
    const waitForAuthServices = () => {
        if (window.AuthService || window.AuthStateManager) {
            window.modernNavbar.updateUserDisplay();
        } else {
            setTimeout(waitForAuthServices, 100);
        }
    };
    
    // Start checking for auth services
    setTimeout(waitForAuthServices, 500);
});

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ModernNavbar;
}
