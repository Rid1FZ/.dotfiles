;;; diredfl.el --- Config For `diredfl' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package diredfl
  :ensure t

  :after
  (dired)

  :hook
  (dired-mode . diredfl-global-mode)

  :commands
  (dired dired-jump))

;;; diredfl.el ends here
