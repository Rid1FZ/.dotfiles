;;; vertico.el --- Config For `vertico' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package vertico
  :ensure t

  :custom
  (vertico-count 15)
  (vertico-cycle t)

  :init
  (vertico-mode))

;; vertico-directory ships with vertico (:ensure nil) — improves path editing
(use-package vertico-directory
  :ensure nil
  :after vertico

  :bind
  (:map vertico-map
        ("DEL"   . vertico-directory-delete-char)
        ("M-DEL" . vertico-directory-delete-word)))

;;; vertico.el ends here
