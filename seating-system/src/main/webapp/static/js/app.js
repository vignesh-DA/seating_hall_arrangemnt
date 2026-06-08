/* app.js — Minimal JS for file upload UX and form feedback */

document.addEventListener('DOMContentLoaded', function () {

    // ---- Drag & drop + file name display for upload cards ----
    const uploadCards = document.querySelectorAll('.upload-card');

    uploadCards.forEach(function(card) {
        const input = card.querySelector('input[type="file"]');
        const nameEl = card.querySelector('.file-name');

        if (!input) return;

        input.addEventListener('change', function () {
            if (input.files.length > 0) {
                card.classList.add('has-file');
                if (nameEl) nameEl.textContent = '✓ ' + input.files[0].name;
            }
        });

        card.addEventListener('dragover', function (e) {
            e.preventDefault();
            card.classList.add('drag-over');
        });
        card.addEventListener('dragleave', function () {
            card.classList.remove('drag-over');
        });
        card.addEventListener('drop', function (e) {
            e.preventDefault();
            card.classList.remove('drag-over');
            if (e.dataTransfer.files.length > 0 && input) {
                input.files = e.dataTransfer.files;
                card.classList.add('has-file');
                if (nameEl) nameEl.textContent = '✓ ' + e.dataTransfer.files[0].name;
            }
        });
    });

    // ---- Generate button loading state ----
    const generateForm = document.getElementById('generateForm');
    const generateBtn  = document.getElementById('generateBtn');

    if (generateForm && generateBtn) {
        generateForm.addEventListener('submit', function () {
            generateBtn.disabled = true;
            generateBtn.innerHTML = '<span>⚙️</span><span>Generating...</span><span class="gc-sub">Please wait while we compute the seating plan</span>';
        });
    }

    // ---- Auto-dismiss alerts after 6 seconds ----
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity .5s ease';
            alert.style.opacity = '0';
            setTimeout(function () { alert.remove(); }, 500);
        }, 6000);
    });

    // ---- Branch color helper for dynamically added cells ----
    function getBranchClass(branch) {
        const map = {
            'CSE': 'branch-CSE',
            'ECE': 'branch-ECE',
            'MECH': 'branch-MECH',
            'IT':   'branch-IT',
            'CIVIL':'branch-CIVIL'
        };
        return map[branch] || 'branch-OTHER';
    }

    // ---- Hall tab switching on seating view ----
    const hallTabs = document.querySelectorAll('.hall-tab');
    const hallPanels = document.querySelectorAll('.hall-panel');

    hallTabs.forEach(function(tab) {
        tab.addEventListener('click', function () {
            hallTabs.forEach(t => t.classList.remove('active'));
            hallPanels.forEach(p => p.classList.remove('active'));
            tab.classList.add('active');
            const target = tab.dataset.hall;
            const panel = document.getElementById('panel-' + target);
            if (panel) panel.classList.add('active');
        });
    });

    // Activate first tab by default
    if (hallTabs.length > 0) hallTabs[0].click();
});
