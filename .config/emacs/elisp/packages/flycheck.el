;;; flycheck.el --- Config For `flycheck' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package flycheck
  :ensure t

  :after
  (lsp-mode)

  :config
  (global-flycheck-mode))

(use-package flycheck-pos-tip
  :ensure t

  :after
  (flycheck)

  :hook
  ((flycheck-mode . flycheck-pos-tip-mode)
   (global-flycheck-mode . flycheck-pos-tip-mode))

  :custom
  (flycheck-pos-tip-timeout 10))

;;; flycheck.el ends here
