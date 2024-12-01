;;; vterm.el --- Config For `vterm' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package vterm
  :ensure t

  :init
  (add-hook 'vterm-exit-functions
	    (lambda (_ _)
	      (let* ((buffer (current-buffer))
		     (window (get-buffer-window buffer)))
		(when (not (one-window-p))
		  (delete-window window))
		(kill-buffer buffer)))))

;;; vterm.el ends here
