{ config, pkgs, ... }:

let
  username = "bouke";
in
  {
    imports = [
      <home-manager/nix-darwin>
    ];
    environment.darwinConfig = "$HOME/dotfiles/darwin.nix";
    environment.systemPackages = with pkgs; [
      alacritty
      fish
      bash
      zsh
      (pkgs.callPackage ./. { })
    ];
    home-manager.users."${username}" = (import ./home.nix);
    users.users."${username}" = {
      home = "/Users/${username}";
      description = "Bouke van der Bijl";
      shell = pkgs.fish;
    };
    environment.shells = with pkgs; [ bashInteractive fish zsh ];
    programs.fish.enable = true;
    system.stateVersion = 4;
    system.defaults.dock.autohide = true;
    services.nix-daemon.enable = false;
    nix.useDaemon = false;
    nix.maxJobs = 4;
    nix.buildCores = 4;
  }
