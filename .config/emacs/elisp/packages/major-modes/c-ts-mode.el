;;; c-ts-mode.el --- Config For `c-ts-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package c-ts-mode
  :ensure nil

  :hook
  (c-ts-mode . eglot-ensure))

;;; c-ts-mode.el ends here
