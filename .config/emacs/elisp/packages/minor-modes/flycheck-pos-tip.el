;;; flycheck-pos-tip.el --- Config For `flycheck-pos-tip' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package flycheck-pos-tip
  :ensure t

  :after
  (flycheck)

  :hook
  (flycheck-mode . flycheck-pos-tip-mode)

  :custom
  (flycheck-pos-tip-timeout 10))

;;; flycheck-pos-tip.el ends here
