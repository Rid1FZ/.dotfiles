;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; user
(setq user-full-name "Ridwan Faiz"
      user-mail-address "rid1.fz.06@gmail.com")


;; font
(setq doom-font (font-spec
                 :family "JetBrainsMono Nerd Font"
                 :size 17
                 :weight 'medium)
      doom-variable-pitch-font (font-spec
                                :family "Ubuntu Nerd Font"
                                :size 17
                                :weight 'medium)
      doom-big-font (font-spec
                     :family "JetBrainsMono Nerd Font"
                     :size 20
                     :weight 'medium)
      doom-symbol-font (font-spec
                        :family "Symbols Nerd Font"))


;; theme and customization
(setq doom-theme 'catppuccin
      catppuccin-flavor 'mocha)

(setq display-line-numbers-type t)


;; misc
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-banner)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)
(assoc-delete-all "Jump to bookmark" +doom-dashboard-menu-sections)
(assoc-delete-all "Open org-agenda" +doom-dashboard-menu-sections)


;; use wl-clipboard for copy-paste
(setq wl-copy-process nil)
(defun wl-copy (text)
  (setq wl-copy-process (make-process :name "wl-copy"
                                      :buffer nil
                                      :command '("wl-copy" "-f" "-n")
                                      :connection-type 'pipe
                                      :noquery t))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))
(defun wl-paste ()
  (if (and wl-copy-process (process-live-p wl-copy-process))
      nil
    (shell-command-to-string "wl-paste -n | tr -d \r")))

(setq interprogram-cut-function 'wl-copy)
(setq interprogram-paste-function 'wl-paste)


;; keybindings
(map! :leader
      :desc "Toggle comment"
      "/" #'comment-line)

;; treesitter
(setq major-mode-remap-alist
      '((yaml-mode . yaml-ts-mode)
        (bash-mode . bash-ts-mode)
        (js2-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (json-mode . json-ts-mode)
        (css-mode . css-ts-mode)
        (python-mode . python-ts-mode)))
