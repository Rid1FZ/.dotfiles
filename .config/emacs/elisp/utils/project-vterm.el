;;; project-vterm.el --- vterm helpers for project.el -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(defun custom/project-run-vterm ()
  "Open vterm at the current project root (current window).
Falls back to `default-directory' if not in a project."
  (interactive)
  (let ((default-directory (if (project-current)
                               (project-root (project-current))
                             default-directory)))
    (vterm)))

(defun custom/project-run-vterm-other-window ()
  "Open vterm at the current project root (other window).
Falls back to `default-directory' if not in a project."
  (interactive)
  (let ((default-directory (if (project-current)
                               (project-root (project-current))
                             default-directory)))
    (vterm-other-window)))

;;; project-vterm.el ends here
