(require 'general)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(general-create-definer normal-mode-leader-definer
  :states 'normal
  :prefix "SPC")

(normal-mode-leader-definer
  "f" '(:ignore t :which-key "Find")
  "ff" '(counsel-find-file :which-key "Find File")
  "fF" '(counsel-projectile-find-file :which-key "Find File(Project)")
  "fg" '(counsel-rg :which-key "rg")
  "fG" '(counsel-projectile-rg :which-key "rg(Project)")
  "fp" '(counsel-projectile-switch-project :which-key "Find Project")
  "fb" '(counsel-switch-buffer :which-key "Find Buffer")
  "fB" '(counsel-projectile-switch-to-buffer :which-key "Find Buffer(Project)"))

(normal-mode-leader-definer
  "o" '(:ignore t :which-key "Open")
  "od" '(dired-jump :which-key "Open Dired")
  "oe" '(treemacs-select-window :which-key "Open Explorer"))

(normal-mode-leader-definer
 :keymaps 'lsp-mode-map
 "l" '(:ignore t :which-key "LSP")
 "la" '(lsp-execute-code-action :which-key "Code Action")
 "ld" '(lsp-ui-doc-glance :which-key "Documentation"))
