;;; projectile.el --- Config For `projectile' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package projectile
  :ensure t
  
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

;;; projectile.el ends here
