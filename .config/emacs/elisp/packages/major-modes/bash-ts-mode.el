;;; bash-ts-mode.el --- Config For `bash-ts-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package bash-ts-mode
  :ensure nil

  :hook
  (bash-ts-mode . eglot-ensure))

;;; bash-ts-mode.el ends here
