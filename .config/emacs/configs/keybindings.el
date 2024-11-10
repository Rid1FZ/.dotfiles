(require 'general)

(general-create-definer normal-mode-leader-definer
  :states 'normal
  :prefix "SPC")

(normal-mode-leader-definer
 :keymaps 'lsp-mode-map
 "l" '(:ignore t :which-key "LSP")
 "la" '(lsp-execute-code-action :which-key "Code Action"))
