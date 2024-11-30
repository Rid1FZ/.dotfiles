;;; updater.el --- Utility functions for Emacs config -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(defun native-recompile-packages ()
  "Prune eln cache and native recompile everything on `package-user-dir'."
  (interactive)
  (native-compile-prune-cache)
  (native-compile-async package-user-dir 'recursively))

(defun upgrade-and-recompile ()
  "Upgrade all packages and natively recompile them."
  (interactive)
  (package-upgrade-all)
  (native-recompile-packages))

;;; updater.el ends here
