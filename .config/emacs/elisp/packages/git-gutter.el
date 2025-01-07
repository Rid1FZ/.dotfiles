;;; git-gutter.el --- Config For `git-gutter' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package git-gutter
  :ensure t

  :init
  (setq git-gutter:update-interval 0.02)

  :custom
  (git-gutter:modified-sign "│")
  (git-gutter:added-sign "│")
  (git-gutter:deleted-sign "│")

  :config
  (global-git-gutter-mode +1)
  (set-face-foreground 'git-gutter:modified "#f9e2af")
  (set-face-foreground 'git-gutter:added "#a6e3a1")
  (set-face-foreground 'git-gutter:deleted "#f38ba8"))

;;; git-gutter.el ends here
