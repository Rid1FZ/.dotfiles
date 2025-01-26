;;; ivy.el --- Config For `ivy' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package ivy
  :ensure t
  :diminish

  :after
  (nerd-icons-ivy-rich swiper)

  :bind
  (("C-s" . swiper)

   :map ivy-minibuffer-map
   ("TAB" . ivy-alt-done)
   ("RET" . ivy-done)
   ("C-n" . ivy-next-line)
   ("C-p" . ivy-previous-line)

   :map ivy-switch-buffer-map
   ("C-k" . ivy-previous-line)
   ("C-l" . ivy-done)
   ("C-d" . ivy-switch-buffer-kill)

   :map ivy-reverse-i-search-map
   ("C-k" . ivy-previous-line)
   ("C-d" . ivy-reverse-i-search-kill))

  :custom
  (ivy-use-selectable-prompt t)
  (ivy-initial-inputs-alist '())

  :config
  (ivy-mode 1))

;;; ivy.el ends here
