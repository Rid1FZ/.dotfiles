set-option -g default-terminal 'tmux-256color'
set-option -g terminal-overrides ",${TERM}:Tc"
set-option -g display-time 1
set-option -s escape-time 0
set-option -g history-limit 50000
set-option -g focus-events on
set-option -g status-interval 1
set-option -g repeat-time 500
set-option -g base-index 1
set-option -g pane-base-index 1
set-option -g renumber-windows on
set-option -g default-shell '/bin/zsh'
set-option -g synchronize-panes off
set-option -g destroy-unattached off
set-option -g mouse on
set-option -g popup-border-lines "rounded"
set-window-option -g mode-keys vi
set-window-option -g pane-base-index 1

# >>> Hooks >>>
set-hook -g pane-mode-changed "run-shell \"~/.config/tmux/scripts/configure-mode-options\""
# <<< Hooks <<<

# >>> Prefix >>>
set-option -g prefix C-Space
bind-key C-Space send-prefix
# <<< Prefix <<<
