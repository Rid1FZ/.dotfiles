;;; projectile.el --- Config For `projectile' package -*- lexical-binding: t -*-

;;; Commentary:

;; This file sets up the `projectile' package and will be sourced from init.el file

;;; Code:

(use-package projectile
  :ensure t
  :diminish projectile-mode
  
  :init
  (when (file-directory-p "~/Projects/")
    (setq projectile-project-search-path '("~/Projects/")))
  (setq projectile-switch-project-action #'projectile-dired)

  :custom
  (projectile-completion-system 'ivy)

  :config
  (projectile-mode)

  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package counsel-projectile
  :ensure t

  :after
  (counsel projectile)

  :hook
  (projectile-mode . counsel-projectile-mode)

  :init
  (require 'counsel))

;;; projectile.el ends here
