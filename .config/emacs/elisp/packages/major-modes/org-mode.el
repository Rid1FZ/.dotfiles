;;; org-mode.el --- Config For `org-mode' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package org
  :ensure nil

  :hook
  (org-mode . org-indent-mode)
  (org-mode . (lambda ()
                (visual-line-mode 1)))

  :custom
  (org-ellipsis " ")

  :config
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "JetBrainsMono Nerd Font Propo" :weight 'medium :height (cdr face))))

(use-package org-bullets
  :ensure t

  :after
  (org)

  :hook
  (org-mode . org-bullets-mode)

  :custom
  (org-bullets-bullet-list '(" ")))


(use-package visual-fill-column
  :ensure t

  :hook
  (org-mode . visual-fill-column-mode)

  :custom
  (visual-fill-column-width 100)
  (visual-fill-column-center-text t))

;;; org-mode.el ends here
