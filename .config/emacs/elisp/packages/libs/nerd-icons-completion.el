;;; nerd-icons-completion.el --- Config For `nerd-icons-completion' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package nerd-icons-completion
  :ensure t
  :after (nerd-icons marginalia)

  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;;; nerd-icons-completion.el ends here
