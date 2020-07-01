{ extraConfig ? "", pkgs ? import <nixpkgs> { }, ... }:
let
  fishConfig = pkgs.writeText "config.fish" ''
${extraConfig}
function fish_user_key_bindings
  source ${pkgs.fzf}/share/fzf/key-bindings.fish && fzf_key_bindings
end

set -p fish_function_path ${./fish/functions}
set -gx GEMRC ${pkgs.writeText "gemrc" ''
  gem: --no-ri --no-rdoc --no-document
  search: --both
''}
set -gx RIPGREP_CONFIG_PATH ${pkgs.writeText "ripgrep" ''
  --smart-case
  --ignore-file=${pkgs.writeText "rgignore" "**/vendor"}
''}
set -gx PRYRC ${pkgs.writeText "pryrc" ''
  Pry.config.hooks.add_hook(:before_session, :show_ruby_version) do
    puts "Ruby #{RUBY_VERSION}\n"
  end
  Pry.config.editor = 'vim'
''}
set -gx IRBRC ${pkgs.writeText "irbrc" ''
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
set -gx INPUTRC ${pkgs.writeText "inputrc" ''
  set completion-ignore-case on
  set show-all-if-ambiguous on
''}
set -gx CTHULHU_DIR $HOME/src/github.internal.digitalocean.com/digitalocean/cthulhu
set -gx EDITOR vim
set -gx EJSON_KEYDIR $HOME/.ejson_keys
set -gx FZF_DEFAULT_COMMAND 'rg --files'
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx VAULT_USERNAME bvanderbijl
set -gx WGETRC ${./wgetrc}
set -gx ZK_DIR "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Notities/Zettelkasten"
set -gxp PATH $HOME/go/bin

function list_after_cd --on-variable PWD
  ls
end
'';
in
  pkgs.symlinkJoin {
    name = "fish";
    paths = [ pkgs.fish ];
    buildInputs = [ pkgs.makeWrapper ];
    passthru = {
      shellPath = pkgs.fish.shellPath;
    };
    postBuild = ''
      bin="$(readlink -v --canonicalize-existing "$out/bin/fish")"
      rm "$out/bin/fish"
      makeWrapper $bin "$out/bin/fish" --add-flags "--init-command \"set -gxp PATH $out/bin; source ${fishConfig}\""
    '';
  }
