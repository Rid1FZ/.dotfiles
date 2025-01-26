;;; init.el --- Bootstrap Package Configs  -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:
(defun load-package-conf(dir)
  "Bootstrap given configs from dir under `user-emacs-directory/elisp/packages'.
DIR: dir to load"
  (mapc 'load-file
        (file-expand-wildcards
         (concat user-emacs-directory "elisp/packages/" dir "/*.el"))))


(load-package-conf "libs")
(load-package-conf "minor-modes")
(load-package-conf "major-modes")

;;; init.el ends here
