;;; flycheck.el --- Config For `flycheck' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package flycheck
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . global-flycheck-mode))

(use-package flycheck-pos-tip
  :ensure t
  :after flycheck
  :hook (flycheck-mode global-flycheck-mode)

  :custom
  (flycheck-pos-tip-timeout 10))

;;; flycheck.el ends here
