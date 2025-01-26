;;; doom-modeline.el --- Config For `doom-modeline' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package doom-modeline
  :ensure t

  :hook
  (after-init . doom-modeline-mode)

  :custom
  (doom-modeline-height 20)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-highlight-modified-buffer-name t)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-icon t)
  (doom-modeline-modal t)
  (doom-modeline-modal-icon nil)
  (doom-modeline-modal-modern-icon nil)
  (nerd-icons-scale-factor 1.2)
  (lsp-modeline-code-action-fallback-icon " ")

  :config
  (custom-set-faces
   '(mode-line ((t (:family "JetBrainsMono Nerd Font Propo" :height 125))))
   '(mode-line-active ((t (:family "JetBrainsMono Nerd Font Propo" :height 125))))
   '(mode-line-inactive ((t (:family "JetBrainsMono Nerd Font Propo" :height 125))))))

;;; doom-modeline.el ends here
