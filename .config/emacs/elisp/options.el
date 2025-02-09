;;; options.el --- Options for Emacs  -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; Reset Defaults
(setq inhibit-startup-message t
      ring-bell-function 'ignore
      initial-scratch-message ";;; -*- lexical-binding: t -*-"
      inhibit-compacting-font-caches t
      case-fold-search nil)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(delete-selection-mode 1)
(blink-cursor-mode 0)
(fset 'yes-or-no-p 'y-or-n-p)

;; Fonts
(set-face-attribute 'default nil
                    :font "JetBrainsMono Nerd Font Propo"
                    :height 120
                    :weight 'medium)

;; Highlight Current Line
(global-hl-line-mode)

;; Disable Line Highlight for Some Modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                help-mode-hook
                inferior-emacs-lisp-mode-hook
                dired-mode-hook))
  (add-hook mode (lambda () (setq-local global-hl-line-mode nil))))

;; Indentation
(setq-default indent-tabs-mode nil
              tab-width 4
              indent-line-function #'insert-tab)

;; Disable Wrap
(global-visual-line-mode -1)
(setq-default truncate-lines t)

;; Line Numbers
(setq display-line-numbers-type 'relative)
(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable Line Numbers for Some Modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                treemacs-mode-hook
                help-mode-hook
                inferior-emacs-lisp-mode-hook
                flycheck-error-list-mode-hook
                dired-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode -1))))

;; Enable Mouse in Terminal Mode
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; Scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse t
      scroll-step 1
      scroll-conservatively most-positive-fixnum)

;; Maximize Window On Startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; Map Modes to Major Modes
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)
        (c-or-c++-mode . c-or-c++-ts-mode)
        (sh-mode . bash-ts-mode)))

;; Autoclose Parens, Quotes, etc...
(electric-pair-mode t)

;; Kill Previous Dired Buffer is New Directory is Visited
(setq dired-kill-when-opening-new-dired-buffer t)

;; Set Font Lock Level for TS Modes
(dolist (mode '(python-ts-mode-hook
                yaml-ts-mode-hook
                toml-ts-mode-hook
                bash-ts-mode-hook
                c-ts-mode-hook
                c++-ts-mode-hook
                c-or-c++-ts-mode-hook))
  (add-hook mode (lambda () (setq-local treesit-font-lock-level 4))))

;; Set Lexical Binding for Emacs Lisp
(add-hook 'emacs-lisp-mode-hook (lambda ()
                                  (setq lexical-binding t)))

;; Enable Mouse Support in Terminal
(add-hook 'after-make-frame-functions
          (lambda ()
            (unless (display-graphics-p)
              (xterm-mouse-mode 1))))

;;; options.el ends here
