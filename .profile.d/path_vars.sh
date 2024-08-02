#!/bin/env bash

# >>> path vairables >>>
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
! [[ "$PATH" =~ $HOME/.local/bin:$HOME/bin: ]] && export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
# <<< path vairables <<<
