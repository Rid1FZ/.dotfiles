;;; init.el --- The init file of Emacs configs -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; Custom Config Loader
(defun load-user-file (file)
  "Load config file from `elisp' directory.
FILE: the name of file inside `elisp' directory"
  (load-file (expand-file-name file (concat user-emacs-directory "elisp"))))

;; Load Utils
(mapc 'load-file (file-expand-wildcards (concat user-emacs-directory "elisp/utils/*.el")))

;; Load Options
(load-user-file "options.el")

;; Setup Package Manager
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(setq package-native-compile t
      native-comp-async-report-warnings-errors nil
      byte-compile-warnings nil)

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Do Not Populate Config Directory
(use-package no-littering
  :ensure t)

;; Load Packages
(load-user-file "packages/init.el")

;; Load Custom Configs
(load-user-file "keybindings.el")

;;; init.el ends here
