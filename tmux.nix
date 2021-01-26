{ pkgs ? import <nixpkgs> { }, ... }:
let
  tmuxConfig = pkgs.writeText "tmux.conf" ''
    ${builtins.readFile ./tmux.conf}
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
