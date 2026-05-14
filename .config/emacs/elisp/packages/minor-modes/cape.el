;;; cape.el --- Config For `cape' -*- lexical-binding: t -*-

;;; Commentary:
;; Cape (Completion At Point Extensions) adds extra completion sources
;; that feed into corfu alongside eglot and yasnippet-capf.

;;; Code:

(use-package cape
  :ensure t

  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

;;; cape.el ends here
