;;; early-init.el --- Early init file of Emacs -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(setq disabled-command-function nil
      make-backup-files nil
      create-lockfiles nil
      evil-want-keybinding nil
      native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings nil
      package-user-dir (expand-file-name "packages/" user-emacs-directory))

;; Disable Autosave for Programming Modes
(add-hook 'prog-mode-hook (lambda ()
                            (auto-save-mode -1)))

;;; early-init.el ends here
