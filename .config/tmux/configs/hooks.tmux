# >>> copy mode >>>
set-hook -g pane-mode-changed 'if -F "#{m/r:(copy|view)-mode,#{pane_mode}}" {
  set-option prefix None
  select-pane -d
  set-option window-status-current-style fg=#a6e3a1
  set-option status-left "#[fg=#a6e3a1]█ "
  set-option status-right " #[fg=#a6e3a1]  █"
  refresh-client -S
} {
  set-option -u prefix
  select-pane -e
  set-option -u window-status-current-style
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
}'
# <<< copy mode <<<

# >>> choose mode >>>
set-hook -g pane-mode-changed 'if -F "#{m/r:(tree|buffer|client|view)-mode,#{pane_mode}}" {
  set-option prefix None
  select-pane -d
  set-option window-status-current-style fg=#f5c2e7
  set-option status-left "#[fg=#f5c2e7]█ "
  set-option status-right " #[fg=#f5c2e7]  █"
  refresh-client -S
} {
  set-option -u prefix
  select-pane -e
  set-option -u window-status-current-style
  set-option -u status-left
  set-option -u status-right
  refresh-client -S
}'
# <<< choose mode <<<
