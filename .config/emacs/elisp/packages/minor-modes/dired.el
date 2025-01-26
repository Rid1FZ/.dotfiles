;;; dired.el --- Config For `dired' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:


;; setting this inside :custom or :init does not work as expected
(setq dired-listing-switches "-go --almost-all --human-readable --group-directories-first")

(use-package dired
  :ensure nil

  :after
  (nerd-icons-dired evil evil-collection)

  :hook
  (dired-mode . nerd-icons-dired-mode)

  :commands
  (dired dired-jump)
  
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))

;;; dired.el ends here
