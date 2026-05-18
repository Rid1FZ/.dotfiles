;;; corfu.el --- Config For `corfu' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package corfu
  :ensure t

  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.0)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-quit-no-match 'separator)

  :bind
  (:map corfu-map
        ("TAB"       . corfu-next)
        ("<tab>"     . corfu-next)
        ("S-TAB"     . corfu-previous)
        ("<backtab>" . corfu-previous))

  :init
  (global-corfu-mode)

  :config
  ;; Only capture RET when a candidate is explicitly selected.
  ;; When nothing is selected (corfu--index = -1), RET falls through
  ;; to the buffer's own binding (newline-and-indent, shell submit, etc.)
  (keymap-set corfu-map "RET"
              `(menu-item "" nil :filter
                          ,(lambda (&optional _)
                             (and (>= corfu--index 0) #'corfu-insert))))

  ;; Disable auto-popup in the minibuffer — conflicts with vertico and
  ;; fires on evil ex (:) commands. TAB still triggers completion.
  (add-hook 'minibuffer-setup-hook
            (lambda ()
              (setq-local corfu-auto nil)))
  (add-hook 'vterm-mode-hook
            (lambda ()
              (corfu-mode -1))))

(use-package corfu-terminal
  :ensure t
  :after corfu

  :config
  (unless (display-graphic-p)
    (corfu-terminal-mode +1)))

;;; corfu.el ends here
