;;; rainbow-delimiters.el --- Config For `rainbow-delimiters' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package rainbow-delimiters
  :ensure t

  :hook
  (prog-mode . rainbow-delimiters-mode)
  (text-mode . rainbow-delimiters-mode))

;;; rainbow-delimiters.el ends here
