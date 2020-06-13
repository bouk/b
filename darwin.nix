{ config, pkgs, ... }:

let
  username = "bouke";
  world = (pkgs.callPackage ./. { });
in
  {
    environment.darwinConfig = "$HOME/dotfiles/darwin.nix";
    environment.systemPackages = with pkgs; [
      (pkgs.callPackage ./alacritty.nix { })
      bash
      zsh
      world
    ];
    environment.etc = {
      "gitconfig" = { source = ./gitconfig; };
      "ssh/ssh_config" = { source = ./ssh_config; };
      "tmux.conf" = { source = ./tmux.conf; };
    };
    users.users."${username}" = {
      home = "/Users/${username}";
      description = "Bouke van der Bijl";
    };
    environment.shells = with pkgs; [ bashInteractive world zsh ];
    system.stateVersion = 4;
    system.defaults.dock.autohide = true;
    services.nix-daemon.enable = false;
    nix.useDaemon = false;
    nix.maxJobs = 4;
    nix.buildCores = 4;
  }
