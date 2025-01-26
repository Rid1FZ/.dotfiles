;;; lsp-ui.el --- Config For `lsp-ui' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package lsp-ui
  :ensure t

  :hook
  (lsp-mode . lsp-ui-mode)

  :init
  (setq lsp-ui-sideline-code-actions-prefix " ")

  :custom
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-side 'right)
  (lsp-ui-sideline-show-diagnostics nil)
  (lsp-ui-sideline-show-code-actions t))

;;; lsp-ui.el ends here
