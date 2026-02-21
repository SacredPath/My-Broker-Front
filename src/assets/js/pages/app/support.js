/**
 * Support Page Controller
 * Handles FAQ functionality, contact form submission, and ticket management
 */

class SupportPage {
  constructor() {
    this.currentUser = null;
    this.tickets = [];
    this.faqItems = null;
    
    // Get API client
    this.api = window.API || null;

    if (!this.api) {
      console.warn("SupportPage: API client not found on load. Retrying in 500ms...");
      setTimeout(() => this.retryInit(), 500);
    } else {
      this.init();
    }
  }

  retryInit() {
    this.api = window.API || null;
    if (this.api) {
      this.init();
    } else {
      // Retry again if API client still not available
      setTimeout(() => this.retryInit(), 500);
    }
  }

  async init() {
    console.log('Support page initializing...');
    
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupPage());
    } else {
      this.setupPage();
    }
  }

  async setupPage() {
    try {
      // Initialize app shell FIRST - this handles all sidebar and theme functionality
      if (window.AppShell) {
        window.AppShell.initShell();
      }
      
      // Load user data
      await this.loadUserData();
      
      // Setup FAQ functionality
      this.setupFAQ();
      
      // Setup contact form
      this.setupContactForm();
      
      // Load support tickets
      await this.loadSupportTickets();
      
      console.log('Support page setup complete');
    } catch (error) {
      console.error('Failed to setup support page:', error);
    }
  }

  async loadUserData() {
    try {
      const userId = await this.api.getCurrentUserId();
      this.currentUser = { id: userId };
      console.log('User data loaded:', this.currentUser);
    } catch (error) {
      console.error('Failed to load user data:', error);
      this.currentUser = null;
    }
  }

  setupFAQ() {
    // FAQ items data
    this.faqItems = [
      {
        question: "How do I deposit funds?",
        answer: "You can deposit funds by navigating to the Deposits page in your dashboard. We support bank transfers, credit/debit cards, and cryptocurrency deposits."
      },
      {
        question: "How long do withdrawals take?",
        answer: "Withdrawal times vary by method: Bank transfers take 3-5 business days, cryptocurrency withdrawals are usually processed within 1-2 hours."
      },
      {
        question: "Is my account secure?",
        answer: "Yes, we use industry-standard encryption and two-factor authentication to protect your account and funds."
      }
    ];

    // Render FAQ items
    const faqContainer = document.getElementById('faq');
    if (faqContainer && this.faqItems) {
      faqContainer.innerHTML = this.faqItems.map((item, index) => `
        <div class="faq-item">
          <div class="faq-question" onclick="window.supportPage.toggleFAQ(${index})">
            <span>${item.question}</span>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
          </div>
          <div class="faq-answer" id="faq-answer-${index}">
            ${item.answer}
          </div>
        </div>
      `).join('');
    }
  }

  toggleFAQ(index) {
    const faqItems = document.querySelectorAll('.faq-item');
    if (faqItems[index]) {
      const answer = faqItems[index].querySelector('.faq-answer');
      const isActive = faqItems[index].classList.contains('active');
      
      // Close all other FAQ items
      faqItems.forEach((item, i) => {
        if (i !== index) {
          item.classList.remove('active');
          const otherAnswer = item.querySelector('.faq-answer');
          if (otherAnswer) {
            otherAnswer.style.display = 'none';
          }
        }
      });
      
      // Toggle current FAQ item
      if (isActive) {
        faqItems[index].classList.remove('active');
        answer.style.display = 'none';
      } else {
        faqItems[index].classList.add('active');
        answer.style.display = 'block';
      }
    }
  }

  setupContactForm() {
    const form = document.getElementById('support-form');
    if (!form) return;

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      await this.submitSupportTicket(e);
    });
  }

  async submitSupportTicket(event) {
    try {
      const formData = new FormData(event.target);
      const ticketData = {
        user_id: this.currentUser?.id,
        subject: formData.get('subject'),
        priority: formData.get('priority'),
        message: formData.get('message'),
        status: 'open',
        created_at: new Date().toISOString()
      };

      // Show loading state
      const submitBtn = event.target.querySelector('button[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.textContent = 'Sending...';
      }

      // Submit to database (you would implement this with your actual API)
      console.log('Support ticket submitted:', ticketData);
      
      // Show success message
      if (window.Notify) {
        window.Notify.success('Support ticket submitted successfully! We\'ll respond within 24 hours.');
      } else {
        alert('Support ticket submitted successfully! We\'ll respond within 24 hours.');
      }

      // Reset form
      event.target.reset();
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Send Message';
      }

    } catch (error) {
      console.error('Failed to submit support ticket:', error);
      if (window.Notify) {
        window.Notify.error('Failed to submit support ticket. Please try again.');
      } else {
        alert('Failed to submit support ticket. Please try again.');
      }
    }
  }

  async loadSupportTickets() {
    try {
      if (!this.currentUser) return;

      // Load user's support tickets from database
      // This would be implemented with your actual API
      const tickets = []; // await this.api.getSupportTickets(this.currentUser.id);
      
      this.tickets = tickets;
      this.renderTicketHistory();

    } catch (error) {
      console.error('Failed to load support tickets:', error);
    }
  }

  renderTicketHistory() {
    const container = document.getElementById('tickets-container');
    if (!container) return;

    if (this.tickets.length === 0) {
      container.innerHTML = `
        <p style="color: var(--text-secondary); text-align: center; padding: 40px;">
          No support tickets found.
        </p>
      `;
    } else {
      container.innerHTML = this.tickets.map(ticket => `
        <div class="support-ticket" style="background: var(--surface); border: 1px solid var(--border); border-radius: 8px; padding: 16px; margin-bottom: 12px;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
            <div>
              <div style="font-weight: 600; color: var(--text);">#${ticket.id}</div>
              <div style="color: var(--text-secondary); font-size: 14px;">${ticket.subject}</div>
            </div>
            <div style="color: var(--text-secondary); font-size: 12px;">${new Date(ticket.created_at).toLocaleDateString()}</div>
          </div>
          <div style="color: var(--text-secondary);">${ticket.message}</div>
          <div style="margin-top: 8px;">
            <span style="padding: 4px 8px; background: ${ticket.status === 'open' ? 'var(--warning)' : 'var(--success)'}; color: white; border-radius: 4px; font-size: 12px;">
              ${ticket.status.toUpperCase()}
            </span>
          </div>
        </div>
      `).join('');
    }
  }
}

// Initialize support page when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  // Support Page Sidebar Autohide Functionality
  console.log('=== SUPPORT SIDEBAR AUTOHIDE INIT ===');
  
  const sidebarToggle = document.querySelector('[data-action="sidebar-toggle"]');
  const sidebar = document.querySelector('[data-role="sidebar"]');
  const overlay = document.querySelector('[data-role="sidebar-overlay"]');
  
  if (sidebarToggle && sidebar && overlay) {
    console.log('Sidebar toggle found:', !!sidebarToggle);
    console.log('Sidebar found:', !!sidebar);
    console.log('Overlay found:', !!overlay);
    
    // Auto-hide sidebar on support page
    sidebar.style.transform = 'translateX(-100%)';
    overlay.style.display = 'none';
    
    // Ensure sidebar toggle still works
    sidebarToggle.addEventListener('click', () => {
      const isOpen = sidebar.style.transform === 'translateX(0px)';
      if (isOpen) {
        sidebar.style.transform = 'translateX(-100%)';
        overlay.style.display = 'none';
      } else {
        sidebar.style.transform = 'translateX(0px)';
        overlay.style.display = 'block';
      }
    });
    
    console.log('Sidebar autohidden by default');
  } else {
    console.log('Some sidebar elements not found');
  }
  
  // Initialize support page
  if (window.SupportPage) {
    window.supportPage = new SupportPage();
  }
});
