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

;;; Bootstrap
(defun custom/bootstrap/native-compile-sync ()
  "Prune eln cache and native recompile everything synchronously."
  (native-compile-prune-cache)
  (let ((dirs (list package-user-dir
                    (expand-file-name "elisp/" user-emacs-directory))))
    (dolist (dir dirs)
      (when (file-directory-p dir)
        (message "compiling: %s..." dir)
        (dolist (file (directory-files-recursively dir "\\.el\\'"))
          (condition-case err
              (native-compile file)
            (error (message "Failed to compile %s: %s" file err)))))
    (message "Synchronous native compilation complete!"))))

(defun custom/bootstrap ()
  "Install packages and `native-compile' everything.  Blocks until done.
Intended for headless use:
 
  emacs --batch -l ~/.config/emacs/early-init.el -l ~/.config/emacs/init.el -f custom/bootstrap"
  (message "[bootstrap] Installing packages...")

  ;; Packages are already installed by init.el at this point.
  ;; Refresh archives + quickstart so the index is up to date.
  (package-quickstart-refresh)

  (message "[bootstrap] Compiling...")
  (custom/bootstrap/native-compile-sync)
  (message "[bootstrap] Done."))
 
;;; updater.el ends here
