;;; treemacs.el --- Config For `treemacs' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package treemacs
  :ensure t

  :after
  (treemacs-nerd-icons)

  :init
  (require 'treemacs-evil)
  (require 'treemacs-projectile)
  (require 'treemacs-magit)
  (require 'treemacs-nerd-icons)

  :config
  (treemacs-project-follow-mode)
  (treemacs-follow-mode -1))

(use-package treemacs-evil
  :ensure t

  :after
  (treemacs evil)

  :init
  (require 'evil))

(use-package treemacs-projectile
  :ensure t

  :after
  (treemacs projectile)

  :init
  (require 'projectile))

(use-package treemacs-magit
  :ensure t

  :after
  (treemacs magit)

  :init
  (require 'magit))

;;; treemacs.el ends here
