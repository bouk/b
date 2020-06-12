{ config, pkgs, lib, ... }:
{
  programs.home-manager.enable = true;
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.neovim = {
    enable = true;
    vimAlias = true;
    withNodeJs = true;
    extraConfig = builtins.readFile ./vimrc;
    plugins = with pkgs.vimPlugins; [
      vim-fish
      deoplete-nvim
      deoplete-clang
      denite-nvim
      editorconfig-vim
      fzf-vim
      nerdtree
      vim-fugitive
      vim-gitgutter
      vim-go
      vim-nix
      yats-vim
      (let
        nvim-typescript = (pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "nvim-typescript";
          version = "2020-06-06";
          src = pkgs.fetchFromGitHub {
            owner = "mhartington";
            repo = "nvim-typescript";
            rev = "cb325b5273e1eba4e8536fdf211a4d7e49b5d6f9";
            sha256 = "0bbbj25jhdx0ls2d7p9ir54hmdxvql9kn3hid1s4h963ww1mah0j";
          };
        });
         # node2nix dynamically resolves nodeDependencies
         nvim-typescript-shell = (pkgs.callPackage (
           pkgs.runCommand "nvim-typescript-rplugin.nix" {
             nativeBuildInputs = [pkgs.nodePackages.node2nix];
           } ''
             mkdir -p $out
             cd ${nvim-typescript.src}/rplugin/node/nvim_typescript
             node2nix --input package.json \
                      --lock package-lock.json \
                      --include-peer-dependencies \
                      --nodejs-10 \
                      --development \
                      --output $out/node-packages.nix \
                      --node-env $out/node-env.nix \
                      --composition $out/default.nix
           ''
         ) {}).shell;
       in
         nvim-typescript.overrideAttrs(old: {
           inherit (nvim-typescript-shell) buildInputs;
           buildPhase = ''
             pushd rplugin/node/nvim_typescript
             cp -r ${nvim-typescript-shell.nodeDependencies}/lib/node_modules node_modules
             npm run build
             popd
           '';
         })
      )
      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "molokai";
        version = "2020-06-05";
        src = pkgs.fetchFromGitHub {
          owner = "bouk";
          repo = "molokai";
          rev = "6d2c463b22b24e83f610355688344afaa2ea05fe";
          sha256 = "050slmghd3r4007h9pdmhcjdid0n2vzkg3pp97wx3747716kn1g9";
        };
      })
      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "deoplete-markdown-links";
        version = "2020-06-05";
        src = pkgs.fetchFromGitHub {
          owner = "bouk";
          repo = "deoplete-markdown-links";
          rev = "517a13941c32e69f07005d6aabf66467731c5ea1";
          sha256 = "0bl8bwrrh2aq822ml8lngrdqv94mzk22h8c6f4lplf6c8wk63fja";
        };
      })
      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "vim-markdown";
        version = "2020-06-05";
        src = pkgs.fetchFromGitHub {
          owner = "bouk";
          repo = "vim-markdown";
          rev = "39fc7eb179b5f2991d17ed8fa40aaf4e0a318bd6";
          sha256 = "13n07ik4cp6y5v0jc10bykcz3bfw67xx49i10gc49m4kd7xm2fvh";
        };
      })
    ];
  };
  programs.fish = {
    enable = true;
    shellInit = ''
export EDITOR=vim
export GEMRC=${pkgs.writeText "gemrc" ''
  gem: --no-ri --no-rdoc --no-document
  search: --both
''}
export RIPGREP_CONFIG_PATH=${pkgs.writeText "ripgrep" ''
  --smart-case
  --ignore-file=${pkgs.writeText "rgignore" "**/vendor"}
''}
export PRYRC=${pkgs.writeText "pryrc" ''
  Pry.config.hooks.add_hook(:before_session, :show_ruby_version) do
    puts "Ruby #{RUBY_VERSION}\n"
  end
  Pry.config.editor = 'vim'
''}
export IRBRC=${pkgs.writeText "irbrc" ''
  #https://github.com/carlhuda/bundler/issues/183#issuecomment-1149953
  if defined?(::Bundler)
    global_gemset = ENV['GEM_PATH'].split(':').grep(/ruby.*@global/).first
    if global_gemset
      all_global_gem_paths = Dir.glob("#{global_gemset}/gems/*")
      all_global_gem_paths.each do |p|
        gem_path = "#{p}/lib"
        $LOAD_PATH << gem_path
      end
    end
  end
  # Use Pry everywhere
  require "rubygems"
  require 'pry'
  Pry.start
  exit
''}
export INPUTRC=${pkgs.writeText "inputrc" ''
  set completion-ignore-case on
  set show-all-if-ambiguous on
''}
export WGETRC=${./wgetrc}
    '';
    plugins = [
      {
        name = "dotfiles";
        src = ./fish;
      }
    ];
  };
  home.file = {
    ".gitconfig" = { source = ./gitconfig; };
    ".tmux.conf" = { source = ./tmux.conf; };
    ".ssh/config" = { source = ./ssh_config; };
    ".config/alacritty/alacritty.yml" = { text = pkgs.callPackage ./alacritty.yml.nix { }; };
  };
  home.stateVersion = "19.09";
}
