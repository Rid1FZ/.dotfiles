;;; ivy-rich.el --- Config For `ivy-rich' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package ivy-rich
  :ensure t

  :after
  (nerd-icons-ivy-rich)

  :hook
  (ivy-mode . ivy-rich-mode)

  :config
  (ivy-rich-mode +1)
  (nerd-icons-ivy-rich-mode +1))

;;; ivy-rich.el ends here
