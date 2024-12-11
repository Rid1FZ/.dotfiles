# >>> resize >>>
bind-key -T prefix r {
  set-option prefix None
  set-option key-table resize
  select-pane -d
  set-option status-right " #[fg=#cba6f7]󰩨  #[fg=#89b4fa]█"
  refresh-client -S
}

bind-key -T resize Escape {
  set-option -u prefix
  set-option -u key-table
  select-pane -e
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
}

bind-key -T resize q {
  set-option -u prefix
  set-option -u key-table
  select-pane -e
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
}

bind-key -r -T resize j resize-pane -D 2
bind-key -r -T resize k resize-pane -U 2
bind-key -r -T resize h resize-pane -L 2
bind-key -r -T resize l resize-pane -R 2
# <<< resize <<<

# >>> copy mode >>>
copymode_enabled="! ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|emacs|lazygit|less|.?top)(diff)?$'"

bind-key -T prefix v if-shell "$copymode_enabled" 'copy-mode -H'
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi a send-keys -X cancel
bind-key -T copy-mode-vi i send-keys -X cancel
# <<< copy mode <<<

bind-key Space run-shell 'tmux choose-tree -Zwf"##{==:##{session_name},#{session_name}}"'
bind-key -r H previous-window
bind-key -r L next-window
bind-key c new-window -c "#{pane_current_path}"
bind-key "|" split-pane -h -c "#{pane_current_path}"
bind-key "_" split-pane -c "#{pane_current_path}"
