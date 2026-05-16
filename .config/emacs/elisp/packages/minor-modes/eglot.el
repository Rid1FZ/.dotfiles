;;; eglot.el --- Config For built-in `eglot' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package eglot
  :ensure nil

  :commands
  (eglot eglot-ensure)

  :custom
  (eglot-autoshutdown t)          ;; shut down server when last buffer closes
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)        ;; jump to definitions outside the project
  (eglot-events-buffer-size 0)
  (eglot-sync-connect nil)        ;; do not log to *EGLOT events* buffer

  :config
  ;; Explicit server entries for languages without auto-detection
  (add-to-list 'eglot-server-programs
               '((c-ts-mode c++-ts-mode c-or-c++-ts-mode) . ("clangd")))
  (add-to-list 'eglot-server-programs
               '(bash-ts-mode . ("bash-language-server" "start"))))

;;; eglot.el ends here
