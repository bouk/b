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
      "fish/nixos-env-preinit.fish".text = ''
        # IDK!!!
        function export --description 'Set env variable. Alias for `set -gx` for bash compatibility.'
            if not set -q argv[1]
                set -x
                return 0
            end
            for arg in $argv
                set -l v (string split -m 1 "=" -- $arg)
                switch (count $v)
                    case 1
                        set -gx $v $$v
                    case 2
                        if contains -- $v[1] PATH CDPATH MANPATH
                            set -l colonized_path (string replace -- "$$v[1]" (string join ":" -- $$v[1]) $v[2])
                            set -gx $v[1] (string split ":" -- $colonized_path)
                        else
                            # status is 1 from the contains check, and `set` does not change the status on success: reset it.
                            true
                            set -gx $v[1] $v[2]
                        end
                end
            end
        end

        # source the NixOS environment config
        if test -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE"
            source ${config.system.build.setEnvironment}
        end
      '';
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
