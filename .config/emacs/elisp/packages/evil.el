;;; evil.el --- Config For `evil' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package key-chord)

(use-package evil
  :ensure t

  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (require 'evil-collection)

  :config
  (evil-mode 1)
  (setq key-chord-two-keys-delay 0.2)
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state) ;; `jk' to quit insert
  (key-chord-mode 1)
  ;; Set initial vim-mode for major modes
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil

  :init
  (evil-collection-init))

;;; evil.el ends here
