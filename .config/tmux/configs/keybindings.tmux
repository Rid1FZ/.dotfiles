# >>> resize >>>
bind-key -T prefix r {
  set-option prefix None
  set-option key-table resize
  select-pane -d
  set-option window-status-current-style fg=#f38ba8
  set-option status-left "#[fg=#f38ba8]█ "
  set-option status-right " 󰩨#[fg=#f38ba8]  █"
  refresh-client -S
}

bind-key -T resize Escape {
  set-option -u prefix
  set-option -u key-table
  select-pane -e
  set-option -u window-status-current-style
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
}

bind-key -r -T resize j resize-pane -D 2
bind-key -r -T resize k resize-pane -U 2
bind-key -r -T resize h resize-pane -L 2
bind-key -r -T resize l resize-pane -R 2
# <<< resize <<<

# >>> choose mode >>>
bind-key -T prefix f {
  set-option prefix None
  set-option key-table choose
  select-pane -d
  set-option window-status-current-style fg=#f5c2e7
  set-option status-left "#[fg=#f5c2e7]█ "
  set-option status-right " #[fg=#f5c2e7]  █"
  refresh-client -S
}

bind-key -T choose Escape {
  set-option -u prefix
  set-option -u key-table
  select-pane -e
  set-option -u window-status-current-style
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
}

bind-key -T choose w {
  set-option -u prefix
  set-option -u key-table
  select-pane -e
  set-option -u window-status-current-style
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
  run-shell 'tmux choose-tree -Zwf"##{==:##{session_name},#{session_name}}"'
}

bind-key -T choose t {
  set-option -u prefix
  set-option -u key-table
  select-pane -e
  set-option -u window-status-current-style
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
  choose-tree -Z
}
# <<< choose mode <<<

# >>> copy mode >>>
copymode_enabled="! ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|less|.?top)(diff)?$'"

bind-key -T prefix v if-shell "$copymode_enabled" 'copy-mode -H'
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi a send-keys -X cancel
bind-key -T copy-mode-vi i send-keys -X cancel
# <<< copy mode <<<

bind-key -r H previous-window
bind-key -r L next-window
bind-key Space run-shell 'tmux choose-tree -Zwf"##{==:##{session_name},#{session_name}}"'
bind-key c new-window -c "#{pane_current_path}"
bind-key s run-shell "~/.config/tmux/scripts/smart-split"
bind-key "|" split-pane -h -c "#{pane_current_path}"
bind-key "_" split-pane -c "#{pane_current_path}"
