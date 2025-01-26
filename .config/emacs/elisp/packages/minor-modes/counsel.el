;;; counsel.el --- Config For `counsel' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package counsel
  :ensure t

  :after
  (ivy ivy-rich)

  :hook
  (counsel-mode . ivy-mode)

  :bind
  ("M-x" . counsel-M-x)
  ("C-x b" . counsel-ibuffer)
  ("C-x C-f" . counsel-find-file)

  (:map minibuffer-local-map
	("C-r" . 'counsel-minibuffer-history)))

;;; counsel.el ends here
