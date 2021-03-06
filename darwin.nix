{ pkgs, config, lib, ... }:

let
  cfge = config.environment;

  fishTranslate = name: input: pkgs.runCommand name { } "${pkgs.babelfish}/bin/babelfish <${input} >$out";
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
in

{
  #require = [ ./launchd.nix ];

  users.users."${username}" = {
    home = "/Users/${username}";
    description = "Bouke van der Bijl";
    shell = world;
  };
  services.nix-daemon.enable = false;
  nix = {
    useDaemon = false;
    maxJobs = 4;
    buildCores = 4;
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 4;
  system.defaults.dock.autohide = true;
  system.activationScripts = {
    # Remove built-in shells and ssh config
    preActivation.text = ''
      echo "deleting /etc/shells and /etc/ssh/ssh_config" >&2
      rm -f /etc/shells
      rm -f /etc/ssh/ssh_config
    '';
    # Set the shell
    postActivation.text = ''
      dscl . -create '/Users/${username}' UserShell '${toShellPath world}'
    '';
  };
  environment = {
    shells = with pkgs; [ bashInteractive world zsh ];
    pathsToLink = ["/"];
    darwinConfig = toString <darwin-config>;
    systemPackages = with pkgs; [
      bashInteractive
      cloudflared
      zsh
      world
    ];
    variables = with pkgs.darwin.apple_sdk.frameworks; {
      EDITOR = "vim";
      SHELL = (toShellPath world);
    };
    etc = {
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
}
