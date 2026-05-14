;;; yasnippet.el --- Config For `yasnippet' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package yasnippet
  :ensure t

  :init
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

;; yasnippet-capf feeds yas snippets into completion-at-point-functions
;; so corfu picks them up without any extra company-* glue
(use-package yasnippet-capf
  :ensure t
  :after (yasnippet cape)

  :init
  (add-hook 'completion-at-point-functions #'yasnippet-capf))

;;; yasnippet.el ends here
