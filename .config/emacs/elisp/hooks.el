;;; hooks.el --- Hooks -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

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

;; Disable Line Highlight for Some Modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                help-mode-hook
                inferior-emacs-lisp-mode-hook
                dired-mode-hook))
  (add-hook mode (lambda () (setq-local global-hl-line-mode nil))))


;; Disable Evil Mode for Some Modes
(dolist (mode '(term-mode-hook
                vterm-mode-hook))
  (add-hook mode (lambda () (evil-local-mode -1))))

;; Enable Mouse Support in Terminal
(add-hook 'after-make-frame-functions
          (lambda ()
            (unless (display-graphics-p)
              (xterm-mouse-mode 1))))

;;; hooks.el ends here
