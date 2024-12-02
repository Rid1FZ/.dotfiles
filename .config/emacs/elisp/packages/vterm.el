;;; vterm.el --- Config For `vterm' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package vterm
  :ensure t

  :init
  (add-hook 'vterm-exit-functions (lambda (_ _)
				    (custom/close-buffer))))

;;; vterm.el ends here
