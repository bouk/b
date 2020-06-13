{ config, pkgs, lib, ... }:
{
  programs.home-manager.enable = true;
  home.file = {
    ".gitconfig" = { source = ./gitconfig; };
    ".tmux.conf" = { source = ./tmux.conf; };
    ".ssh/config" = { source = ./ssh_config; };
  };
  home.stateVersion = "19.09";
}
