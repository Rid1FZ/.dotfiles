;;; evil.el --- Config For `evil' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package key-chord
  :ensure t)

(use-package evil
  :ensure t

  :after
  (key-chord)

  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (require 'evil-collection)

  :custom
  (key-chord-two-keys-delay 0.2)

  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state) ;; `jk' to quit insert
  (key-chord-mode 1)
  ;; Initial evil state for major modes
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after
  (evil)

  :init
  (evil-collection-init))

;; Disable Evil Mode for Some Modes
(dolist (mode '(term-mode-hook
                vterm-mode-hook))
  (add-hook mode (lambda () (evil-local-mode -1))))

;;; evil.el ends here
