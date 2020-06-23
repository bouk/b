{ pkgs ? import <nixpkgs> { }, ... }:
let
  tmuxConfig = pkgs.writeText "tmux.conf" ''
    unbind C-b # Don't torture me
    setw -g mode-keys vi
    set -g prefix C-f
    set -gs escape-time 0
    set -g history-limit 10000
    set -g renumber-windows on
    bind s split-window -v -c '#{pane_current_path}'
    bind v split-window -h -c '#{pane_current_path}'
    bind c new-window -c '#{pane_current_path}'
    # Apperance
    # set -g default-terminal "screen-256color"
    set  -g default-terminal "alacritty"
    # set -ag terminal-overrides ",alacritty:Tc"
    # Moving between panes
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R
    bind-key -r M-k resize-pane -U 20
    bind-key -r M-j resize-pane -D 20
    bind-key -r M-h resize-pane -L 20
    bind-key -r M-l resize-pane -R 20

    ${
      if builtins.match ".*darwin" builtins.currentSystem != null then
      ''
      set -g status-right ' #h'
      ''
      else
      ''
      set -g status-right '#h'
      ''
    }
    set -g status-left ""
    set -g status-bg green
    set-option -ga update-environment ' ZK_DIR'
    if-shell "test -f ~/.tmux.custom.conf" "source-file ~/.tmux.custom.conf"
    '';
in
  pkgs.symlinkJoin {
    name = "tmux";
    paths = [ pkgs.tmux ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      bin="$(readlink -v --canonicalize-existing "$out/bin/tmux")"
      rm "$out/bin/tmux"
      makeWrapper $bin "$out/bin/tmux" --add-flags "-f ${tmuxConfig}"
    '';
  }
