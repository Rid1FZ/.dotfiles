;;; treemacs.el --- Config For `treemacs' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package treemacs
  :ensure t

  :after
  (treemacs-nerd-icons)

  :config
  (treemacs-load-theme "nerd-icons")
  (treemacs-project-follow-mode +1)
  (treemacs-follow-mode -1))

;;; treemacs.el ends here
