;;; lsp-mode.el --- Config For `lsp-mode' package -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(use-package lsp-mode
  :ensure t

  :commands
  (lsp lsp-deferred)

  :hook
  (lsp-mode . (lambda ()
		(setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
		(setq lsp-headerline-breadcrumb-icons-enable t)
		(lsp-headerline-breadcrumb-mode)))

  :init
  (require 'lsp-ivy)
  (require 'lsp-treemacs)
  (setq lsp-keymap-prefix "C-c l")

  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :ensure t

  :hook
  (lsp-mode . lsp-ui-mode)

  :init
  (setq lsp-ui-sideline-code-actions-prefix " ")

  :custom
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-side 'right)
  (lsp-ui-sideline-show-diagnostics nil)
  (lsp-ui-sideline-show-code-actions t))

(use-package lsp-ivy
  :ensure t

  :after
  (lsp-mode lsp-ui)

  :init
  (require 'ivy))

(use-package lsp-treemacs
  :ensure t

  :after
  (lsp-mode lsp-ui)

  :init
  (require 'treemacs))

;; Language Specific Plugins
(use-package lsp-pyright
  :ensure t
  
  :hook
  (python-ts-mode . (lambda ()
		      (require 'lsp-pyright)
		      (lsp-deferred)))

  :custom
  (lsp-pyright-langserver-command "basedpyright")) ;; basedpyright/pyright


(use-package c++-ts-mode
  :ensure nil

  :hook
  (c++-ts-mode . lsp-deferred))

(use-package c-ts-mode
  :ensure nil

  :hook
  (c-ts-mode . lsp-deferred))

;;; lsp-mode.el ends here
