;;; yasnippet.el --- Config For `yasnippet' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package yasnippet
  :ensure t
  :after company-mode

  :hook
  (company-mode . yas-global-mode))

;;; yasnippet.el ends here
