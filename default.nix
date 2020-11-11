{ overlays ? [], ... }:

let
  pkgs = import <nixpkgs> { overlays = overlays ++ [ (import ./overlays) ]; };

  boukeBin = pkgs.runCommand "bouke-bin" { } ''
    mkdir $out
    ln -sf ${./bin} $out/bin
  '';

  ruby = pkgs.ruby_2_7;
  paths = with pkgs; [
    (pkgs.callPackage ./tmux.nix { })
    (pkgs.callPackage ./vim.nix { })
    autoconf
    automake
    awscli
    axel
    bat
    bazel
    boukeBin
    cargo
    cmake
    coreutils
    curl
    dbmate
    doctl
    fd
    findutils
    ffmpeg
    fly
    fzf
    gdb
    gitAndTools.hub
    p7zip
    gnused
    gnutar
    go
    golangci-lint
    gopls # Needed until vim-go package requires it properly
    haskellPackages.cabal-install
    haskellPackages.ghc
    htop
    humanlog
    ifacemaker
    imagemagick
    jq
    kind
    kubectl
    luajit
    mockgen
    mysql80
    nmap
    nodePackages.node2nix
    nodePackages.typescript
    nodejs
    patchelf
    postgresql
    protobuf
    python
    ripgrep
    rustc
    s3cmd
    shellcheck
    sqlite
    subversion
    terraform_0_13
    tparse
    tree
    wget
    wrangler
    xz
    yarn
    youtube-dl
    zlib
  ] ++ [ ruby ];
  env = pkgs.buildEnv {
    name = "bouke";
    paths = paths;
    extraOutputsToInstall = [ "bin" "dev" "lib" ];
  };
  # NOTE: here I am doing what nix-shell does with NIX_LDFLAGS and stuff.
  # I am adding all the libraries that are put into the env (like libxml2)
  # into the compiler paths.
  # This means I don't have to use a nix-shell to do basic stuff like build nokogiri.
  # This means of course that I'm using this beautiful nix system to have reproducible stuff,
  # only to throw it all into the global environment.
  # I just want my set-up to be reproducible though.
  # When I build stuff using the tools in my setup, it can just be a mess and that's fine.
  boukeFish = (pkgs.callPackage ./fish.nix {
    extraConfig = ''
      set -gxp CPATH ${pkgs.lib.makeSearchPathOutput "dev" "include" [ pkgs.libxml2 pkgs.libxslt ] }
      set -gxp LIBRARY_PATH ${pkgs.lib.makeLibraryPath [ pkgs.libxml2 pkgs.libxslt ] }
      set -gxp PATH $HOME/.gem/ruby/${ruby.version.libDir}/bin ${pkgs.lib.makeBinPath [ env ] }
      '';
  });
  package = boukeFish;
in
  if pkgs.lib.inNixShell
  then
    pkgs.mkShell {
      shellHook = "${package}${package.shellPath}; exit $?";
    }
  else package
