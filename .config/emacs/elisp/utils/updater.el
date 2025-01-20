;;; updater.el --- package updater and compiler -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(defun custom/native-recompile-packages ()
  "Prune eln cache and native recompile everything on `package-user-dir'."
  (interactive)
  (native-compile-prune-cache)
  (native-compile-async package-user-dir 'recursively))

(defun custom/upgrade-and-recompile ()
  "Upgrade all packages and natively recompile them."
  (interactive)
  (package-upgrade-all)
  (if (y-or-n-p "recompile all packages?")
      (custom/native-recompile-packages)))

;;; updater.el ends here
