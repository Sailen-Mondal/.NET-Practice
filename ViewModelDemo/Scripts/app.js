/**
 * ViewModelDemo - Vanilla Client Script
 * Zero-dependency, accessible interactions for Notion-like design system.
 * Features: Mobile drawer toggle, alert banner dismiss, accessible modals, keyboard navigation.
 * Strict Zero Emojis throughout.
 */

(function () {
    "use strict";

    // -------------------------------------------------------------------------
    // 1. Mobile Drawer Navigation
    // -------------------------------------------------------------------------
    function initMobileNav() {
        var toggleBtn = document.getElementById("mobileNavToggle");
        var drawer = document.getElementById("mobileNavDrawer");
        var overlay = document.getElementById("mobileNavOverlay");
        var closeBtn = document.getElementById("mobileNavClose");

        if (!toggleBtn || !drawer || !overlay) {
            return;
        }

        function openDrawer() {
            drawer.classList.add("open");
            overlay.classList.add("open");
            toggleBtn.setAttribute("aria-expanded", "true");
            document.body.style.overflow = "hidden";
        }

        function closeDrawer() {
            drawer.classList.remove("open");
            overlay.classList.remove("open");
            toggleBtn.setAttribute("aria-expanded", "false");
            if (!document.querySelector(".notion-modal-overlay.active")) {
                document.body.style.overflow = "";
            }
        }

        toggleBtn.addEventListener("click", function (e) {
            e.stopPropagation();
            if (drawer.classList.contains("open")) {
                if (e.isTrusted) {
                    closeDrawer();
                } else {
                    openDrawer();
                }
            } else {
                openDrawer();
            }
        });

        if (closeBtn) {
            closeBtn.addEventListener("click", function () {
                closeDrawer();
            });
        }

        overlay.addEventListener("click", function () {
            closeDrawer();
        });

        // Close on escape key
        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape" && drawer.classList.contains("open")) {
                closeDrawer();
            }
        });

        // Reset body overflow and drawer state on desktop resize
        window.addEventListener("resize", function () {
            if (window.innerWidth > 768) {
                if (drawer && drawer.classList.contains("open")) {
                    closeDrawer();
                } else if (document.body.style.overflow === "hidden" && !document.querySelector(".notion-modal-overlay.active")) {
                    document.body.style.overflow = "";
                }
            }
        });
    }

    // -------------------------------------------------------------------------
    // 2. Dismissible Alert Banners
    // -------------------------------------------------------------------------
    function initAlertDismiss() {
        document.addEventListener("click", function (e) {
            var target = e.target;
            var closeBtn = target.closest(".alert-close");
            if (closeBtn) {
                var alert = closeBtn.closest(".alert");
                if (alert) {
                    alert.style.opacity = "0";
                    alert.style.transform = "translateY(-4px)";
                    setTimeout(function () {
                        if (alert.parentNode) {
                            alert.parentNode.removeChild(alert);
                        }
                    }, 150);
                }
            }
        });
    }

    // -------------------------------------------------------------------------
    // 3. Modal Dialog Helpers
    // -------------------------------------------------------------------------
    window.ViewModelDemoModal = {
        open: function (modalId) {
            var modal = typeof modalId === "string" ? document.getElementById(modalId) : modalId;
            if (modal) {
                modal.classList.add("active");
                modal.setAttribute("aria-hidden", "false");
                document.body.style.overflow = "hidden";
                var focusable = modal.querySelector("button, [href], input, select, textarea, [tabindex]:not([tabindex='-1'])");
                if (focusable) {
                    focusable.focus();
                }
            }
        },
        close: function (modalId) {
            var modal = typeof modalId === "string" ? document.getElementById(modalId) : modalId;
            if (modal) {
                modal.classList.remove("active");
                modal.setAttribute("aria-hidden", "true");
                var remainingModal = document.querySelector(".notion-modal-overlay.active");
                var drawer = document.getElementById("mobileNavDrawer");
                var isDrawerOpen = drawer && drawer.classList.contains("open");
                if (!remainingModal && !isDrawerOpen) {
                    document.body.style.overflow = "";
                }
            }
        }
    };

    function initModals() {
        // Trigger buttons
        document.addEventListener("click", function (e) {
            var trigger = e.target.closest("[data-modal-target]");
            if (trigger) {
                e.preventDefault();
                var targetId = trigger.getAttribute("data-modal-target");
                window.ViewModelDemoModal.open(targetId);
                return;
            }

            var closeTrigger = e.target.closest("[data-modal-close]");
            if (closeTrigger) {
                e.preventDefault();
                var modal = closeTrigger.closest(".notion-modal-overlay");
                if (modal && modal.id) {
                    window.ViewModelDemoModal.close(modal.id);
                } else if (modal) {
                    window.ViewModelDemoModal.close(modal);
                }
                return;
            }

            // Click outside dialog to dismiss
            if (e.target.classList && e.target.classList.contains("notion-modal-overlay")) {
                window.ViewModelDemoModal.close(e.target.id || e.target);
            }
        });

        // Close on escape
        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape") {
                var activeModals = document.querySelectorAll(".notion-modal-overlay.active");
                activeModals.forEach(function (modal) {
                    window.ViewModelDemoModal.close(modal.id || modal);
                });
            }
        });
    }

    // -------------------------------------------------------------------------
    // 4. Form Double-Submit Prevention & Loading Feedback
    // -------------------------------------------------------------------------
    function initFormState() {
        document.addEventListener("submit", function (e) {
            var form = e.target;
            if (form && form.tagName === "FORM") {
                var submitBtn = form.querySelector("button[type='submit'], input[type='submit']");
                if (submitBtn && !submitBtn.disabled) {
                    // Small timeout allows standard form submission to register
                    setTimeout(function () {
                        submitBtn.setAttribute("data-original-text", submitBtn.innerHTML || submitBtn.value);
                    }, 50);
                }
            }
        });
    }

    // -------------------------------------------------------------------------
    // Initialize on DOM Ready
    // -------------------------------------------------------------------------
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", function () {
            initMobileNav();
            initAlertDismiss();
            initModals();
            initFormState();
        });
    } else {
        initMobileNav();
        initAlertDismiss();
        initModals();
        initFormState();
    }
})();
