;;; early-init.el --- Early init file of Emacs -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(setq disabled-command-function nil
      make-backup-files nil ;; disable backup files
      create-lockfiles nil ;; disable lockfiles
      custom-file (expand-file-name "emacs/custom.el" "~/.local/state/") ;; change location of custom configs
      package-user-dir (expand-file-name "packages/" user-emacs-directory)) ;; change location of installed packages

(load custom-file 'noerror)

;; Disable Autosave FIles
(add-hook 'prog-mode-hook (lambda ()
			    (interactive)
			    (auto-save-mode -1)))

;;; early-init.el ends here
