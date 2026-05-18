;;; early-init.el --- Early init file of Emacs -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; Emacs checks every file load against file-name-handler-alist.
;; Disable this during startup for performance.
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist my/file-name-handler-alist)))

(setq disabled-command-function nil
      make-backup-files nil
      create-lockfiles nil
      evil-want-keybinding nil
      read-process-output-max (* 1024 1024) ;; set read buffer to 1MiB for lesser system calls
      package-quickstart t
      native-comp-async-jobs-number (num-processors)
      native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings '(not obsolete)
      warning-minimum-log-level :warning
      package-user-dir (expand-file-name "packages/" user-emacs-directory))

;; Disable Autosave for Programming Modes
(add-hook 'prog-mode-hook (lambda ()
                            (auto-save-mode -1)))

;; These options are needed to be set before init.el is sourced
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(add-to-list 'initial-frame-alist '(fullscreen . maximized)) ;; maximize window on startup

;; Tune the grabage collector for performance
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;;; early-init.el ends here
