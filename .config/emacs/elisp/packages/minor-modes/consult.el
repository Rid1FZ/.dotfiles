;;; consult.el --- Config For `consult' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package consult
  :ensure t

  :bind
  (("C-s" . consult-line))

  :custom
  ;; Only preview on explicit M-. rather than on every selection movement
  (consult-preview-key "M-.")
  ;; Wire xref (M-. jump to definition) through consult for better UI
  (xref-show-xrefs-function      #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

;;; consult.el ends here
