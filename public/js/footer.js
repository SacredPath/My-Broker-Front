// Footer JavaScript Component
document.addEventListener('DOMContentLoaded', function() {
    // Newsletter Form Handler
    const newsletterForm = document.getElementById('newsletter-form');
    const newsletterMessage = document.getElementById('newsletter-message');
    
    if (newsletterForm) {
        newsletterForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const email = this.querySelector('.newsletter-input').value;
            
            // Show success message
            newsletterMessage.textContent = 'Thank you for subscribing! Check your email for confirmation.';
            newsletterMessage.className = 'newsletter-message success';
            
            // Clear form
            this.querySelector('.newsletter-input').value = '';
            
            // Hide message after 5 seconds
            setTimeout(() => {
                newsletterMessage.textContent = '';
                newsletterMessage.className = 'newsletter-message';
            }, 5000);
        });
    }

    // Back to Top Button
    const backToTop = document.getElementById('back-to-top');
    
    if (backToTop) {
        // Show/hide button based on scroll position
        window.addEventListener('scroll', function() {
            if (window.pageYOffset > 300) {
                backToTop.classList.add('visible');
            } else {
                backToTop.classList.remove('visible');
            }
        });
        
        // Scroll to top when clicked
        backToTop.addEventListener('click', function() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }

    // Language Select Handler
    const languageSelect = document.getElementById('language-select');
    if (languageSelect) {
        languageSelect.addEventListener('change', function() {
            // Here you would typically handle language change
            console.log('Language changed to:', this.value);
            // For now, just show a message
            const message = document.createElement('div');
            message.className = 'language-change-message';
            message.textContent = `Language changed to ${this.options[this.selectedIndex].text}`;
            message.style.cssText = `
                position: fixed;
                bottom: 20px;
                left: 50%;
                transform: translateX(-50%);
                background: var(--primary);
                color: white;
                padding: 12px 24px;
                border-radius: 8px;
                z-index: 1000;
                animation: slideUp 0.3s ease;
            `;
            document.body.appendChild(message);
            
            setTimeout(() => {
                message.remove();
            }, 3000);
        });
    }
});
