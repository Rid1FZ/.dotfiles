#!/bin/env bash

function smart-split {
  width="$(tmux display-message -p '#{pane_width}')"
  height="$(($(tmux display-message -p '#{pane_height}')*2+10))"
  
  if [[ "${width}" -gt "${height}" ]]; then
    tmux split-pane -h -c  '#{pane_current_path}'
  else
    tmux split-pane -c '#{pane_current_path}'
  fi
}

smart-split
