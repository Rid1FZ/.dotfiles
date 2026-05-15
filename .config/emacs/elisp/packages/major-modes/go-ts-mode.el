;;; go-ts-mode.el --- Config For `go-ts-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package go-ts-mode
  :ensure nil
  :mode "\\.go\\'"

  :hook
  (go-ts-mode . eglot-ensure)

  :custom
  (go-ts-mode-indent-offset 2))

;;; go-ts-mode.el ends here
