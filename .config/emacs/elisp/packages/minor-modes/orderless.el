;;; orderless.el --- Config For `orderless' -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package orderless
  :ensure t

  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;;; orderless.el ends here
