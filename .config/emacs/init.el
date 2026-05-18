;;; init.el --- The init file of Emacs configs -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; Check if it is first launch. Will be use at the very end of this file
(defvar custom/is-first-launch (not (file-directory-p package-user-dir)))

;; Custom Config Loader
(defun load-user-file (file)
  "Load config file from `elisp' directory.
FILE: the name of file inside `elisp' directory"
  (load-file (expand-file-name file (concat user-emacs-directory "elisp"))))

;; Load Utils
(mapc (lambda (f) (load (file-name-sans-extension f)))
      (file-expand-wildcards (concat user-emacs-directory "elisp/utils/*.el")))

;; Load Options
(load-user-file "options.el")

;; Setup Package Manager
(require 'package)
(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                         ("elpa"   . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(setq package-native-compile t)

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Keep config directory clean — must load before custom-file is read
(use-package no-littering
  :ensure t)

;; Set and load custom-file after no-littering resolves its path
(setq custom-file (no-littering-expand-var-file-name "custom.el"))
(load custom-file 'noerror)

;; Load Packages
(load-user-file "packages/init.el")

;; Load Keybindings
(load-user-file "keybindings.el")

;; Tune the garbage collector for performance(needed here along with early-init.el)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; If first launch, compile config to native binary
(when custom/is-first-launch
  (add-hook 'emacs-startup-hook #'custom/native-recompile)
  (package-quickstart-refresh))

;;; init.el ends here
