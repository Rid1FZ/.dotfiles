;;; evil-terminal-cursor-changer.el --- Config For `evil-terminal-cursor-changer' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package evil-terminal-cursor-changer
  :ensure t

  :config
  (unless (display-graphic-p)
    (evil-terminal-cursor-changer-activate)))

;;; evil-terminal-cursor-changer.el ends here
