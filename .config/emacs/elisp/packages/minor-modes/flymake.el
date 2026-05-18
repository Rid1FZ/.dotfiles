;;; flymake.el --- Config For built-in `flymake' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package flymake
  :ensure nil

  :hook
  (prog-mode . flymake-mode)

  :bind
  (:map flymake-mode-map
        ("]d" . flymake-goto-next-error)
        ("[d" . flymake-goto-prev-error))

  :custom
  ;; Show diagnostics in the echo area immediately on point movement
  (flymake-no-changes-timeout 0.5))

;;; flymake.el ends here
