{ config, pkgs, lib, ... }:
{
  programs.home-manager.enable = true;
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
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
