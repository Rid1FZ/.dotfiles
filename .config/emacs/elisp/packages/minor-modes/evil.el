;;; evil.el --- Config For `evil' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package evil
  :ensure t

  :after
  (key-chord)

  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)

  :config
  (evil-mode +1)
  (evil-set-undo-system 'undo-redo)
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state) ;; `jk' to quit insert
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; Disable Evil Mode for Some Modes
(dolist (mode '(term-mode-hook
                vterm-mode-hook))
  (add-hook mode (lambda () (evil-local-mode -1))))

;;; evil.el ends here
