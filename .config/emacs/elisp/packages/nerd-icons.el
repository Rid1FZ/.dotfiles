;;; nerd-icons.el --- Config For `nerd-icons' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :ensure t

  :after
  (nerd-icons)

  :hook
  (dired-mode . nerd-icons-dired-mode)

  :init
  (require 'nerd-icons))

(use-package treemacs-nerd-icons
  :ensure t

  :after
  (nerd-icons)

  :init
  (require 'nerd-icons)

  :config
  (treemacs-load-theme "nerd-icons"))

(use-package nerd-icons-ivy-rich
  :ensure t

  :after
  (nerd-icons)

  :init
  (require 'nerd-icons)

  :config
  (nerd-icons-ivy-rich-mode 1))

;;; nerd-icons.el ends here
