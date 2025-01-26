;;; counsel-projectile.el --- Config For `counsel-projectile' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package counsel-projectile
  :ensure t

  :after
  (counsel projectile ivy ivy-rich)

  :config
  (counsel-projectile-mode +1))

;;; counsel-projectile.el ends here
