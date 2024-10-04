# >>> copy mode >>>
set-hook -g pane-mode-changed 'if -F "#{m/r:(copy|view)-mode,#{pane_mode}}" {
  set-option prefix None
  select-pane -d
  set-option status-left "#[fg=#a6e3a1]█"
  set-option status-right "#[fg=#a6e3a1]  █"
  set-option window-status-current-format "#[fg=#a6e3a1] #I:#W "
  refresh-client -S
} {
  set-option -u prefix
  select-pane -e
  set-option -u status-left
  set-option -u status-right
  set-option -u window-status-current-format
  refresh-client -S
}'
# <<< copy mode <<<
