{ pkgs, config, lib, ... }:

let
  cfge = config.environment;

  babelfish = pkgs.buildGoModule rec {
    pname = "babelfish";
    version = "0.1.3";
    src = pkgs.fetchFromGitHub {
      owner = "bouk";
      repo = "babelfish";
      rev = "v${version}";
      sha256 = "08i4y4fw60ynamr1jz8nkfkidxj06vcyhi1v4wxpl2macn6n4skk";
    };
    vendorSha256 = "0xjy50wciw329kq1nkd7hhaipcp4fy28hhk6cdq21qwid6g21gag";
  };

  fishTranslate = name: input: pkgs.runCommand name { } "${babelfish}/bin/babelfish <${input} >$out";
  fishTranslateStr = name: input: fishTranslate name (pkgs.writeText name input);
  setEnvironment = fishTranslate "fish-set-env" config.system.build.setEnvironment;
  # TODO: contribute to NixPkgs
  shellInit = fishTranslateStr "shellInit" cfge.shellInit;
  loginShellInit = fishTranslateStr "loginShellInit" cfge.loginShellInit;
  interactiveShellInit = fishTranslateStr "interactiveShellInit" cfge.interactiveShellInit;
  toShellPath = v: if lib.types.shellPackage.check v then "/run/current-system/sw${v.shellPath}" else v; 

  username = "bouke";
  world = (pkgs.callPackage ./. {
    overlays = [
      (self: super: {
        go = super.go.overrideAttrs(oldAttrs: {
          CC_FOR_TARGET = "clang";
        });
      })
    ];
  });
  mod = {
    users.users."${username}" = {
      home = "/Users/${username}";
      description = "Bouke van der Bijl";
      shell = world;
    };
    environment.shells = with pkgs; [ bashInteractive world zsh ];
    system.stateVersion = 4;
    system.defaults.dock.autohide = true;
    services.nix-daemon.enable = false;
    nix = {
      useDaemon = false;
      maxJobs = 4;
      buildCores = 4;
    };
    # Set the shell
    system.activationScripts.postActivation.text = ''
      dscl . -create '/Users/${username}' UserShell '${toShellPath world}'
    '';
    environment.pathsToLink = ["/"];
    environment.darwinConfig = toString <darwin-config>;
    environment.systemPackages = with pkgs; [
      (pkgs.callPackage ./alacritty.nix { })
      bashInteractive
      zsh
      world
    ];
    environment.variables = with pkgs.darwin.apple_sdk.frameworks; {
      EDITOR = "vim";
      SHELL = (toShellPath world);
    };
    environment.etc = {
      gitconfig.text = import ./gitconfig.nix;
      "ssh/ssh_config".source = ./ssh_config;
      "fish/nixos-env-preinit.fish".text = ''
        # source the NixOS environment config
        if test -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE"
            source ${setEnvironment}
        end
      '';
      "fish/config.fish".text = ''
        # /etc/fish/config.fish: DO NOT EDIT -- this file has been generated automatically.

        # if we haven't sourced the general config, do it
        if not set -q __fish_nix_darwin_general_config_sourced
          source ${shellInit}

          # and leave a note so we don't source this config section again from
          # this very shell (children will source the general config anew)
          set -g __fish_nix_darwin_general_config_sourced 1
        end

        # if we haven't sourced the login config, do it
        status --is-login; and not set -q __fish_nix_darwin_login_config_sourced
        and begin
          source ${loginShellInit}

          # and leave a note so we don't source this config section again from
          # this very shell (children will source the general config anew)
          set -g __fish_nix_darwin_login_config_sourced 1
        end

        # if we haven't sourced the interactive config, do it
        status --is-interactive; and not set -q __fish_nix_darwin_interactive_config_sourced
        and begin
          source ${interactiveShellInit}

          # and leave a note so we don't source this config section again from
          # this very shell (children will source the general config anew,
          # allowing configuration changes in, e.g, aliases, to propagate)
          set -g __fish_nix_darwin_interactive_config_sourced 1
        end
      '';
    };
  };
in
  mod
