;;; buffer-closer.el --- current buffer closer -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(defun custom/close-buffer()
  (interactive)
  (let* ((buffer (current-buffer))
	 (window (get-buffer-window buffer)))
    (kill-buffer buffer)
    (when (not (one-window-p))
      (delete-window window))))

;;; buffer-closer.el ends here
