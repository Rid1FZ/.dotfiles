(use-package company
  :after lsp-mode
  :bind (
	 :map
          company-active-map
          ("<tab>" . company-complete-selection)
          ("RET" . (lambda ()
                     (interactive)
                     (if (company-explicit-action-p)
                       (company-complete)
                       (progn
                         (open-line 1)
                         (next-line 1)))))
          ("<return>" . (lambda ()
                     (interactive)
                     (if (company-explicit-action-p)
                       (company-complete)
                       (progn
                         (open-line 1)
                         (next-line 1))))))
        (:map
          lsp-mode-map
          ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  :config
  (setq company-format-margin-function #'company-vscode-dark-icons-margin))

(setq company-auto-complete-chars nil)
(add-hook 'after-init-hook 'global-company-mode)
