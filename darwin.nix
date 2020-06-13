{ config, pkgs, ... }:

let
  username = "bouke";
  world = (pkgs.callPackage ./. { });
in
  {
    imports = [
      <home-manager/nix-darwin>
    ];
    environment.darwinConfig = "$HOME/dotfiles/darwin.nix";
    environment.systemPackages = with pkgs; [
      (pkgs.callPackage ./alacritty.nix { })
      bash
      zsh
      world
    ];
    home-manager.users."${username}" = (import ./home.nix);
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
