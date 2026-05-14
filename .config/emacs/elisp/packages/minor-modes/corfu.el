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
  (corfu-quit-no-match 'separator)

  :bind
  (:map corfu-map
        ("TAB"       . corfu-next)
        ("<tab>"     . corfu-next)
        ("S-TAB"     . corfu-previous)
        ("<backtab>" . corfu-previous)
        ("RET"       . corfu-insert)
        ("<return>"  . corfu-insert))

  :init
  (global-corfu-mode))

;; corfu-terminal adds popup support in terminal frames
(use-package corfu-terminal
  :ensure t
  :after corfu

  :config
  (unless (display-graphic-p)
    (corfu-terminal-mode +1)))

;;; corfu.el ends here
