function c
    set -l dirs ~/dotfiles ~/code/* ~/src/{github.internal.digitalocean.com/digitalocean/,}cthulhu/docode/src/do/teams/{compute,paas}/* ~/src/{bou.ke,k8s.io,github{.internal.digitalocean,}.com/*}/*
    set -l directory (command ls -d -1 $dirs 2>/dev/null | fzf --tiebreak=length,begin,end)
    if test -n "$directory"
        and test -d $directory
        cd $directory
    end
end
