/**
 * CFM Landing Page - Interactive Elements
 */

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offset = 80; // Navigation height + padding
            const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - offset;
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// Add scroll effect to navigation
const nav = document.querySelector('.nav');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;
    
    if (currentScroll > 100) {
        nav.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)';
    } else {
        nav.style.boxShadow = 'none';
    }
    
    lastScroll = currentScroll;
});

// Animate stats on scroll
const observerOptions = {
    threshold: 0.5,
    rootMargin: '0px'
};

const animateValue = (element, start, end, duration) => {
    const startTimestamp = Date.now();
    const step = () => {
        const timestamp = Date.now();
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        const value = Math.floor(progress * (end - start) + start);
        element.textContent = value + (element.dataset.suffix || '');
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
};

const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.classList.contains('animated')) {
            const statValue = entry.target.querySelector('.stat-card-value');
            if (statValue) {
                const value = parseInt(statValue.textContent);
                if (!isNaN(value)) {
                    statValue.dataset.suffix = statValue.textContent.replace(/\d+/g, '');
                    animateValue(statValue, 0, value, 1000);
                    entry.target.classList.add('animated');
                }
            }
            
            // Animate progress bar
            const progressFill = entry.target.querySelector('.progress-fill');
            if (progressFill && !progressFill.classList.contains('animated')) {
                setTimeout(() => {
                    progressFill.style.width = progressFill.style.width;
                    progressFill.classList.add('animated');
                }, 100);
            }
        }
    });
}, observerOptions);

// Observe all stat cards
document.querySelectorAll('.stat-card').forEach(card => {
    statsObserver.observe(card);
});

// Feature cards animation
const featureObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting && !entry.target.classList.contains('visible')) {
            setTimeout(() => {
                entry.target.style.opacity = '0';
                entry.target.style.transform = 'translateY(20px)';
                entry.target.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                    entry.target.classList.add('visible');
                }, 50);
            }, index * 100);
        }
    });
}, {
    threshold: 0.1
});

// Observe all feature cards
document.querySelectorAll('.feature-card').forEach(card => {
    featureObserver.observe(card);
});

// Steps animation
const stepsObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting && !entry.target.classList.contains('visible')) {
            setTimeout(() => {
                entry.target.style.opacity = '0';
                entry.target.style.transform = 'scale(0.9)';
                entry.target.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'scale(1)';
                    entry.target.classList.add('visible');
                }, 50);
            }, index * 150);
        }
    });
}, {
    threshold: 0.3
});

// Observe all steps
document.querySelectorAll('.step').forEach(step => {
    stepsObserver.observe(step);
});

// Mobile menu toggle (for future implementation)
const createMobileMenu = () => {
    const navWrapper = document.querySelector('.nav-wrapper');
    const mobileMenuBtn = document.createElement('button');
    mobileMenuBtn.className = 'mobile-menu-btn';
    mobileMenuBtn.innerHTML = `
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 12h18M3 6h18M3 18h18"/>
        </svg>
    `;
    
    // Add mobile menu button styles
    const style = document.createElement('style');
    style.textContent = `
        .mobile-menu-btn {
            display: none;
            background: none;
            border: none;
            cursor: pointer;
            padding: 8px;
            color: var(--cal-text);
        }
        
        @media (max-width: 768px) {
            .mobile-menu-btn {
                display: block;
            }
        }
    `;
    document.head.appendChild(style);
    
    // Check if mobile
    if (window.innerWidth <= 768) {
        navWrapper.appendChild(mobileMenuBtn);
    }
    
    window.addEventListener('resize', () => {
        if (window.innerWidth <= 768 && !navWrapper.contains(mobileMenuBtn)) {
            navWrapper.appendChild(mobileMenuBtn);
        } else if (window.innerWidth > 768 && navWrapper.contains(mobileMenuBtn)) {
            mobileMenuBtn.remove();
        }
    });
};

// Initialize mobile menu
createMobileMenu();

// Add loading animation for buttons
document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('click', function(e) {
        // Don't add loading for navigation links
        if (this.getAttribute('href')?.startsWith('#')) return;
        
        // Add ripple effect
        const ripple = document.createElement('span');
        ripple.className = 'ripple';
        this.appendChild(ripple);
        
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
        ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';
        
        setTimeout(() => ripple.remove(), 600);
    });
});

// Add ripple effect styles
const rippleStyle = document.createElement('style');
rippleStyle.textContent = `
    .btn {
        position: relative;
        overflow: hidden;
    }
    
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: scale(0);
        animation: ripple 0.6s ease-out;
        pointer-events: none;
    }
    
    @keyframes ripple {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(rippleStyle);

// Log page load
console.log('CFM Landing Page loaded successfully');
console.log('Bot: https://t.me/CFmatch_bot');
console.log('GitHub: https://github.com/Rivega42/cfm-bot');