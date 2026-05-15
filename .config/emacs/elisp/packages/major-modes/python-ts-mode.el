;;; python-ts-mode.el --- Config For `python-ts-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package python
  :ensure nil

  :hook
  (python-ts-mode . eglot-ensure)

  :custom
  (python-indent-offset 2))

;;; python-ts-mode.el ends here
