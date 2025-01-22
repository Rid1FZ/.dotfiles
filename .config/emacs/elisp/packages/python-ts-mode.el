;;; python-ts-mode.el --- Config For `python-ts-mode' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package python-ts-mode
  :ensure nil

  :after
  (lsp-pyright)

  :hook
  (python-ts-mode . lsp-deferred)

  :init
  (require 'lsp-pyright))

;;; python-ts-mode.el ends here
