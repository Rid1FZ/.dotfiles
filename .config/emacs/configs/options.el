;; Set "Custom File's" Path
(setq disabled-command-function nil)
(setq custom-file "~/.local/state/emacs/custom.el")
(load custom-file 'noerror)

;; Reset Defaults
(setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(blink-cursor-mode 0)
(fset 'yes-or-no-p 'y-or-n-p)

;; Disable Backup/Lock/Autosave Files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(add-hook 'prog-mode-hook (lambda ()
			    (interactive)
			    (auto-save-mode -1)))

;; Fonts
(set-face-attribute 'default nil
                    :font "JetBrainsMono Nerd Font Propo"
                    :height 120
                    :weight 'medium)

;; Line Numbers
(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable Line Numbers for Some Modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                treemacs-mode-hook
		help-mode-hook
                inferior-emacs-lisp-mode-hook
		flycheck-error-list-mode-hook
		dired-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time
(setq scroll-conservatively most-positive-fixnum)

;; Maximize Window On Startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; Map Modes to Major Modes
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
	(c-mode . c-ts-mode)
	(c++-mode . c++-ts-mode)
	(c-or-c++-mode . c-or-c++-ts-mode)))

;; Autoclose Parens, Quotes, etc...
(electric-pair-mode t)

;; Hooks
(add-hook 'python-ts-mode-hook (lambda ()
				 (setq treesit-font-lock-level 4)))
