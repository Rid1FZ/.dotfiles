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
                   (black "--quiet" "--line-length", "120")
                   (isort))
                  ("Shell"
                   (shfmt "--indent" "4" "--case-indent" "--language-dialect" "bash"))
                  ("C"
                   (clang-format "--style={ BasedOnStyle: Google, AlignAfterOpenBracket: Align, AllowShortBlocksOnASingleLine: 'false', AllowShortCaseLabelsOnASingleLine: 'false', AllowShortFunctionsOnASingleLine: InlineOnly, AllowShortIfStatementsOnASingleLine: Always, IndentWidth: '4', SortUsingDeclarations: 'true', SpaceAfterCStyleCast: 'false', SpacesInAngles: 'false', SpacesInParentheses: 'false', SpacesInSquareBrackets: 'true', TabWidth: '4', UseTab: Never }")))))


;;; format-all.el ends here
