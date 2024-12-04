;;; hooks.el --- Hooks -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(add-hook 'python-ts-mode-hook (lambda ()
				 (setq treesit-font-lock-level 4)))

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
