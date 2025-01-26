;;; c-ts-mode.el --- Config For `c-ts-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package c-ts-mode
  :ensure nil

  :hook
  (c-ts-mode . lsp-deferred))

;;; c-ts-mode.el ends here
