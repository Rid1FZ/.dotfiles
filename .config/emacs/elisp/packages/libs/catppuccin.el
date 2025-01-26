;;; catppuccin.el --- Config For `catppuccin' theme -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package catppuccin-theme
  :ensure t

  :custom
  (catppuccin-highlight-matches t)
  (catppuccin-italic-comments t)
  (catppuccin-flavor 'mocha)

  :init
  (load-theme 'catppuccin :no-confirm))

;;; catppuccin.el ends here
