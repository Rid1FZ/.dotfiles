;; Custom Config Loader
(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file "~/.config/emacs/configs")))

;; Load Options
(load-user-file "options.el")

;; Setup Package Manager
(require 'package)
(setq package-archives '(
                         ("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ))

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

;; Load Packages
(use-package no-littering)
(mapc 'load-file (file-expand-wildcards "~/.config/emacs/configs/packages/*.el"))

;; Load Custom Configs
(load-user-file "keybindings.el")
