// Mobile Bottom Navigation Controller
// Handles active states and navigation for mobile bottom navigation

class MobileBottomNav {
    constructor() {
        this.init();
    }

    init() {
        // Wait for DOM to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.setup());
        } else {
            this.setup();
        }
    }

    setup() {
        // Only setup on mobile devices
        if (!this.isMobile()) return;

        this.loadMobileNavHTML().then(() => {
            this.nav = document.getElementById('mobile-bottom-nav');
            if (!this.nav) return;

            this.links = this.nav.querySelectorAll('.mobile-bottom-nav-link');
            this.currentPage = this.getCurrentPage();
            
            this.setActiveState();
            this.bindEvents();
            this.adjustMainContent();
        });
    }

    async loadMobileNavHTML() {
        try {
            const response = await fetch('/components/mobile-bottom-nav.html');
            const html = await response.text();
            const container = document.getElementById('mobile-bottom-nav-container');
            if (container) {
                container.innerHTML = html;
            }
        } catch (error) {
            console.error('Failed to load mobile bottom navigation:', error);
        }
    }

    isMobile() {
        return window.innerWidth <= 768;
    }

    getCurrentPage() {
        // Extract current page from URL or data attributes
        const path = window.location.pathname;
        const pageMap = {
            '/app/home.html': 'home',
            '/app/': 'home',
            '/app': 'home',
            '/app/tiers.html': 'tiers',
            '/app/deposits.html': 'deposits',
            '/app/portfolio.html': 'portfolio',
            '/app/more.html': 'more',
            '/home.html': 'home',
            '/': 'home'
        };

        // Check exact matches first
        if (pageMap[path]) {
            return pageMap[path];
        }

        // Check partial matches
        for (const [key, value] of Object.entries(pageMap)) {
            if (path.includes(key) || key.includes(path)) {
                return value;
            }
        }

        // Default to home if no match found
        return 'home';
    }

    setActiveState() {
        this.links.forEach(link => {
            const page = link.getAttribute('data-page');
            if (page === this.currentPage) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }

    bindEvents() {
        // Handle link clicks
        this.links.forEach(link => {
            link.addEventListener('click', (e) => {
                // Add ripple effect
                this.createRippleEffect(e, link);
                
                // Update active state with a slight delay for smooth transition
                setTimeout(() => {
                    this.setActiveState();
                }, 100);
            });

            // Handle touch events for better mobile experience
            link.addEventListener('touchstart', (e) => {
                link.style.transform = 'scale(0.95)';
            });

            link.addEventListener('touchend', (e) => {
                setTimeout(() => {
                    link.style.transform = '';
                }, 150);
            });
        });

        // Handle window resize
        window.addEventListener('resize', () => {
            if (this.isMobile()) {
                this.adjustMainContent();
            }
        });

        // Handle page visibility changes
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && this.isMobile()) {
                this.setActiveState();
            }
        });
    }

    createRippleEffect(event, element) {
        const ripple = document.createElement('span');
        ripple.style.position = 'absolute';
        ripple.style.borderRadius = '50%';
        ripple.style.background = 'rgba(255, 255, 255, 0.3)';
        ripple.style.width = '20px';
        ripple.style.height = '20px';
        ripple.style.animation = 'ripple 0.6s ease-out';
        ripple.style.pointerEvents = 'none';
        ripple.style.zIndex = '1000';

        const rect = element.getBoundingClientRect();
        const size = 20;
        ripple.style.left = `${event.clientX - rect.left - size / 2}px`;
        ripple.style.top = `${event.clientY - rect.top - size / 2}px`;

        element.style.position = 'relative';
        element.style.overflow = 'hidden';
        element.appendChild(ripple);

        setTimeout(() => {
            ripple.remove();
        }, 600);
    }

    adjustMainContent() {
        // Adjust main content padding to account for bottom nav
        const mainElements = document.querySelectorAll('main, .main-content, .app-main');
        const navHeight = this.nav ? this.nav.offsetHeight : 65;

        mainElements.forEach(main => {
            if (window.innerWidth <= 768) {
                main.style.paddingBottom = `${navHeight + 15}px`;
            } else {
                main.style.paddingBottom = '';
            }
        });
    }

    // Public method to update active state (can be called from other scripts)
    updateActiveState() {
        this.currentPage = this.getCurrentPage();
        this.setActiveState();
    }

    // Public method to show/hide navigation
    show() {
        if (this.nav && this.isMobile()) {
            this.nav.style.display = 'flex';
            this.adjustMainContent();
        }
    }

    hide() {
        if (this.nav) {
            this.nav.style.display = 'none';
            // Reset main content padding
            const mainElements = document.querySelectorAll('main, .main-content, .app-main');
            mainElements.forEach(main => {
                main.style.paddingBottom = '';
            });
        }
    }
}

// Add ripple animation CSS
const rippleCSS = `
@keyframes ripple {
    to {
        transform: scale(4);
        opacity: 0;
    }
}
`;

// Inject ripple CSS
const style = document.createElement('style');
style.textContent = rippleCSS;
document.head.appendChild(style);

// Initialize mobile bottom navigation
const mobileBottomNav = new MobileBottomNav();

// Make it globally accessible
window.mobileBottomNav = mobileBottomNav;

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MobileBottomNav;
}
