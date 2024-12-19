;;; keybindings.el --- Custom keybindings  -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

(require 'general)


(general-create-definer normal-mode-leader-definer
  :states 'normal
  :prefix "SPC")

(general-create-definer visual-mode-leader-definer
  :states '(visual visual-block visual-line)
  :prefix "SPC")

(general-define-key
 "<escape>" 'keyboard-escape-quit)

(general-define-key
 :keymaps 'vterm-mode-map
 "C-w" 'evil-window-map)

(general-define-key
 :states 'normal
 "gc" '(comment-line :which-key "Toggle Comment(Line)"))

(general-define-key
 :states '(visual visual-line visual-block)
 "gc" '(comment-or-uncomment-region :which-key "Toggle Comment(Region)"))

(normal-mode-leader-definer
  "w" '(evil-window-map :which-key "Window"))

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
  "oe" '(treemacs-select-window :which-key "Open Explorer")
  "ot" '(projectile-run-vterm-other-window :which-key "Open Vterm(Other Window)")
  "oT" '(projectile-run-vterm :which-key "Open Vterm(Current Window)"))

(normal-mode-leader-definer
  "b" '(:ignore t :which-key "Buffer")
  "bf" '(format-all-region-or-buffer :which-key "Format Region or Buffer")
  "bc" '(custom/close-buffer :which-key "Close Buffer")
  "bC" '(projectile-kill-buffers :which-key "Kill Buffers(Project)")
  "bw" '(write-file :which-key "Write Buffer to File")
  "bs" '(save-buffer :which-key "Save Buffer")
  "bk" '(kill-buffer :which-key "Select and Kill Buffer"))

(normal-mode-leader-definer
  :keymaps 'lsp-mode-map
  "l" '(:ignore t :which-key "LSP")
  "la" '(lsp-execute-code-action :which-key "Code Action")
  "ld" '(lsp-ui-doc-glance :which-key "Documentation"))

(visual-mode-leader-definer
  "b" '(:ignore t :which-key "Buffer")
  "bf" '(format-all-region-or-buffer :which-key "Format Region or Buffer"))

;;; keybindings.el ends here
