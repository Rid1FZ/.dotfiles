(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 20)
           (doom-modeline-buffer-file-name-style 'relative-to-project)
           (doom-modeline-highlight-modified-buffer-name t)
           (doom-modeline-modal t)
           (doom-modeline-icon nil)
           (doom-modeline-modal-icon nil)
           (doom-modeline-modal-modern-icon nil)
           (nerd-icons-scale-factor 1.3)
           ))

(custom-set-faces
  '(mode-line ((t (:family "JetBrainsMono Nerd Font Propo" :height 125))))
  '(mode-line-active ((t (:family "JetBrainsMono Nerd Font Propo" :height 125)))) ; For 29+
  '(mode-line-inactive ((t (:family "JetBrainsMono Nerd Font Propo" :height 125)))))
