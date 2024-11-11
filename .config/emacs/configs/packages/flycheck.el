(use-package flycheck
  :ensure t
  :after lsp-mode
  :init (global-flycheck-mode))

(use-package flycheck-pos-tip
  :ensure t
  :after flycheck
  :init (flycheck-pos-tip-mode)

  :custom
  (flycheck-pos-tip-timeout 10))
