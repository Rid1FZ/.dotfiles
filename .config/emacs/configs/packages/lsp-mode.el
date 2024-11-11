(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (setq lsp-headerline-breadcrumb-icons-enable t)
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)

  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'

  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :hook (prog-mode . lsp-ui-mode)

  :custom
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-side 'right)
  (lsp-ui-sideline-show-diagnostics nil))

(use-package lsp-ivy
  :ensure t
  :after (lsp-mode lsp-ui))

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode lsp-ui))

;; Language Specific Plugins
(use-package lsp-pyright
  :ensure t
  :custom (lsp-pyright-langserver-command "basedpyright") ;; basedpyright/pyright
  :hook (python-ts-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred))))

(use-package c++-ts-mode
  :ensure nil
  :hook (c++-ts-mode . lsp-deferred))

(use-package c-ts-mode
  :ensure nil
  :hook (c-ts-mode . lsp-deferred))
