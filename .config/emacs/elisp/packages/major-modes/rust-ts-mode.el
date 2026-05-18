;;; rust-ts-mode.el --- Config For `rust-ts-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package rust-ts-mode
  :ensure nil
  :mode "\\.rs\\'"

  :hook
  (rust-ts-mode . eglot-ensure)

  :custom
  (rust-ts-mode-indent-offset 2))

;;; rust-ts-mode.el ends here
