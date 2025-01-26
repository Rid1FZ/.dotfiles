;;; lsp-pyright.el --- Config For `lsp-pyright' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package lsp-pyright
  :ensure t
  
  :custom
  (lsp-pyright-langserver-command "basedpyright")) ;; basedpyright/pyright

;;; lsp-pyright.el ends here
