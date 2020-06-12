function ls
    set -l param --color=auto
    if isatty 1
        set -a param --indicator-style=classify -h -l --group-directories-first --no-group
    end
    command ls $param $argv
end
