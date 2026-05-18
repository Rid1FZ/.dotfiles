;;; updater.el --- package updater and compiler -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(defun custom/native-recompile ()
  "Prune eln cache and native recompile everything."
  (interactive)
  (native-compile-prune-cache)
  (native-compile-async package-user-dir 'recursively)
  (native-compile-async (expand-file-name "elisp/" user-emacs-directory) 'recursively))

(defun custom/upgrade-and-recompile ()
  "Upgrade all packages and natively recompile them."
  (interactive)
  (package-upgrade-all)
  (package-quickstart-refresh)
  (if (y-or-n-p "recompile all packages?")
      (custom/native-recompile)))

;;; updater.el ends here
