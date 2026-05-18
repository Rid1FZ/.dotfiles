;;; bash-ts-mode.el --- Config For `bash-ts-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package bash-ts-mode
  :ensure nil

  :hook
  (bash-ts-mode . eglot-ensure)

  :custom
  (sh-basic-offset 2))

;;; bash-ts-mode.el ends here
