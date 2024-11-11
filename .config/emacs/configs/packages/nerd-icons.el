(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :ensure t
  :after nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package treemacs-nerd-icons
  :ensure t
  :after nerd-icons

  :config
  (treemacs-load-theme "nerd-icons"))

(use-package nerd-icons-ivy-rich
  :ensure t
  :after nerd-icons

  :init
  (nerd-icons-ivy-rich-mode 1))
