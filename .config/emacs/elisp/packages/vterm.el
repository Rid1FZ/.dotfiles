;;; vterm.el --- Config For `vterm' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package vterm
  :ensure t

  :commands
  (vterm vterm-other-window)

  :init
  (add-hook 'vterm-exit-functions (lambda (&rest _)
                                    (custom/close-buffer))))

;;; vterm.el ends here
