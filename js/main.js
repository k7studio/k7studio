// Mobile menu toggle
document.querySelector('.mobile-menu-button').addEventListener('click', function() {
    document.querySelector('.mobile-menu').classList.toggle('hidden');
});

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();

        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });

        // Close mobile menu if open
        document.querySelector('.mobile-menu').classList.add('hidden');
    });
});