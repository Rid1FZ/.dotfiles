;;; magit.el --- Config For `magit' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package magit
  :ensure t

  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;;; magit.el ends here
