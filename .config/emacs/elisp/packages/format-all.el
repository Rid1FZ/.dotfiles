;;; format-all.el --- Config For `format-all' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package format-all
  :ensure t

  :hook
  (prog-mode . format-all-mode)

  :custom
  (format-all-show-errors "Never")

  :config
  (setq-default format-all-formatters
                '(("Python"
                   (black "--quiet")
                   (isort))
                  ("Shell"
                   (shfmt "-i" "4" "-ci"))
                  ("C"
                   (clang-format)))))


;;; format-all.el ends here
