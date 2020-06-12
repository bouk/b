function f
    rg $argv | fzf-tmux -- --bind='enter:execute($EDITOR {})' --ansi
end
