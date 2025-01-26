;;; lsp-mode.el --- Config For `lsp-mode' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package lsp-mode
  :ensure t

  :commands
  (lsp lsp-deferred)

  :hook
  (lsp-mode . (lambda ()
                (setq lsp-headerline-breadcrumb-segments '(file symbols))
                (setq lsp-headerline-breadcrumb-icons-enable t)
                (lsp-headerline-breadcrumb-mode t)))

  :init
  (setq lsp-keymap-prefix "C-c l")

  :config
  (lsp-enable-which-key-integration t))

;;; lsp-mode.el ends here
