{ pkgs ? import <nixpkgs> { }, ... }:

let
  mockgen = pkgs.buildGoModule rec {
    pname = "mockgen";
    version = "1.4.3";
    src = pkgs.fetchFromGitHub {
      owner = "golang";
      repo = "mock";
      rev = "v${version}";
      sha256 = "1p37xnja1dgq5ykx24n7wincwz2gahjh71b95p8vpw7ss2g8j8wx";
    };
    vendorSha256 = "1kpiij3pimwv3gn28rbrdvlw9q5c76lzw6zpa12q6pgck76acdw4";
    subPackages = [ "mockgen" ];
  };

  ifacemaker = pkgs.buildGoModule rec {
    pname = "ifacemaker";
    version = "1.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "vburenin";
      repo = "ifacemaker";
      rev = "v${version}";
      sha256 = "1cifa3gpfks96vfzscc71v5f3g34c6kcifcgpvn9fn10dk9cqa4s";
    };
    vendorSha256 = "1mzkj4j9wzi5m3mlb78hyjgzdxbxcxh2si1f6pppbxi555bnsrih";
  };

  tparse = pkgs.buildGoModule rec {
    pname = "tparse";
    version = "0.7.4";
    src = pkgs.fetchFromGitHub {
      owner = "mfridman";
      repo = "tparse";
      rev = "v${version}";
      sha256 = "1aqi9qpfrcfajbnmmi3lzv3jrgdijvix5m1566rai5dizcm6kbpc";
    };
    vendorSha256 = "15m1br43hbp2ws2mnssgqvcna9z15l6yvy89jqhgz79p1l0bj4bx";
  };

  humanlog = pkgs.buildGoModule rec {
    pname = "humanlog";
    version = "0.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "aybabtme";
      repo = "humanlog";
      rev = "${version}";
      sha256 = "1d5fs1sk61ksxbs5nyd3l4238jy2wxn0c3h8aamic5sy3mwr7gnv";
    };
    subPackages = [ "cmd/humanlog" ];
  };

  flyOverride = pkgs.buildGoModule rec {
    pname = "fly";
    version = "5.8.0";
    src = pkgs.fetchFromGitHub {
      owner = "concourse";
      repo = "concourse";
      rev = "v${version}";
      sha256 = "0ji3jya4b2b4l6dlvydh3k2jfh6kkhii23d6rmi49ypydhn1qmgj";
    };
    vendorSha256 = "1zzb7n54hnl99lsgln9pib2anmzk5zmixga5x68jyrng91axjifb";
    subPackages = [ "fly" ];
    buildFlagsArray = ''
      -ldflags=
        -X github.com/concourse/concourse.Version=${version}
    '';
  };

  boukeBin = pkgs.runCommand "bouke-bin" { } ''
    mkdir $out
    ln -sf ${./bin} $out/bin
  '';

  paths = with pkgs; [
    (pkgs.callPackage ./tmux.nix { })
    (pkgs.callPackage ./vim.nix { })
    autoconf
    automake
    awscli
    bat
    boukeBin
    cargo
    clang
    cmake
    coreutils
    curl
    doctl
    fd
    findutils
    flyOverride
    fzf
    gdb
    gitAndTools.hub
    gnused
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
    libiconv
    libxml2
    libxslt
    luajit
    mockgen
    mysql80
    nmap
    nodePackages.node2nix
    nodePackages.typescript
    nodejs
    postgresql
    protobuf
    python
    ripgrep
    ruby
    rustc
    shellcheck
    sqlite
    subversion
    tparse
    tree
    wget
    wrangler
    xz
    yarn
    youtube-dl
    zlib
  ];
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
      set -gxp CPATH ${pkgs.lib.makeSearchPathOutput "dev" "include" [ env ] }
      set -gxp LIBRARY_PATH ${pkgs.lib.makeLibraryPath [ env ] }
      set -gxp PATH ${pkgs.lib.makeBinPath [ env ] }
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
