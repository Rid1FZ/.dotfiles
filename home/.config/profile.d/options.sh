#!/bin/env bash

# >>> Options >>>
shopt -s autocd \
    checkjobs \
    checkwinsize \
    cmdhist \
    dotglob \
    extglob \
    extquote \
    failglob \
    histappend

set -o emacs -o histexpand -o pipefail
# <<< Options <<<
