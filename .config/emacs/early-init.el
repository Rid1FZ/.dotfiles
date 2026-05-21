;;; early-init.el --- Early init file of Emacs -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; Emacs checks every file load against file-name-handler-alist.
;; Disable this during startup for performance.
(defvar user/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist user/file-name-handler-alist)))

(require 'xdg)

(defvar user/emacs-cache-dir
  (expand-file-name "emacs/" (xdg-cache-home))
  "Emacs cache directory. Defaults to ~/.cache/emacs/.")

(defvar user/emacs-local-dir
  (expand-file-name "emacs/" (xdg-data-home))
  "Emacs local/data directory. Defaults to ~/.local/share/emacs/.")

;; Ensure directories exist early so downstream code never fails on mkdir.
(dolist (dir (list user/emacs-cache-dir user/emacs-local-dir))
  (unless (file-directory-p dir)
    (make-directory dir :parents)))

(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (expand-file-name "eln-cache/" user/emacs-cache-dir)))

(setq disabled-command-function nil
      make-backup-files nil
      create-lockfiles nil
      evil-want-keybinding nil
      read-process-output-max (* 1024 1024) ;; set read buffer to 1MiB for lesser system calls
      native-comp-async-jobs-number (/ (num-processors) 2)
      native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings '(not obsolete)
      warning-minimum-log-level :warning
      package-user-dir  (expand-file-name "packages/" user/emacs-local-dir)
      package-quickstart t
      package-quickstart-file (expand-file-name "package-quickstart.el" user/emacs-local-dir))

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
