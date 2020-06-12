set -gx ZK_DIR "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Notities/Zettelkasten"
set -pgx PATH $HOME/.nix-profile/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin
#set -pgx PATH $HOME/bin $HOME/dotfiles/bin $HOME/go/bin $HOME/cthulhu/docode/bin /usr/local/go/bin $HOME/.cargo/bin /usr/local/opt/coreutils/libexec/gnubin /usr/local/opt/findutils/libexec/gnubin /usr/local/opt/gawk/libexec/gnubin /usr/local/opt/gnu-indent/libexec/gnubin /usr/local/opt/gnu-sed/libexec/gnubin /usr/local/opt/gnu-tar/libexec/gnubin /usr/local/opt/grep/libexec/gnubin /usr/local/opt/make/libexec /usr/local/opt/python/libexec/bin
set -gx CTHULHU_DIR $HOME/cthulhu
set -gx EDITOR vim
set -gx FZF_DEFAULT_COMMAND 'rg --files'
set -gx VAULT_USERNAME bvanderbijl
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx EJSON_KEYDIR $HOME/.ejson_keys

function list_after_cd --on-variable PWD
  ls
end
