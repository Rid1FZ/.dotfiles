;;; ivy.el --- Config For `ivy' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package ivy
  :ensure t
  :diminish
  :after nerd-icons-ivy-rich

  :bind
  (("C-s" . swiper)

   :map ivy-minibuffer-map
   ("TAB" . ivy-alt-done)
   ("C-l" . ivy-alt-done)
   ("C-j" . ivy-next-line)
   ("C-k" . ivy-previous-line)
   ("RET" . ivy-done)

   :map ivy-switch-buffer-map
   ("C-k" . ivy-previous-line)
   ("C-l" . ivy-done)
   ("C-d" . ivy-switch-buffer-kill)

   :map ivy-reverse-i-search-map
   ("C-k" . ivy-previous-line)
   ("C-d" . ivy-reverse-i-search-kill))

  :config
  (ivy-mode 1))

(use-package ivy-rich
  :ensure t

  :after
  (nerd-icons-ivy-rich)

  :hook
  (ivy-mode . ivy-rich-mode)

  :init
  (require 'nerd-icons-ivy-rich)

  :config
  (ivy-rich-mode 1))

;;; ivy.el ends here
