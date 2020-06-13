{ pkgs ? import <nixpkgs> { }, ... }:
let
  alacrittyConfig = pkgs.writeText "alacritty.yml" (pkgs.callPackage ./alacritty.yml.nix { });
in
  pkgs.symlinkJoin {
    name = "alacritty-configured";
    paths = [ pkgs.alacritty ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      bin="$(readlink -v --canonicalize-existing "$out/bin/alacritty")"
      rm "$out/bin/alacritty"
      makeWrapper $bin "$out/bin/alacritty" --add-flags "--config-file ${alacrittyConfig}"
      ${pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
      rm "$out/Applications/Alacritty.app/Contents/MacOS/alacritty"
      ln -sn ../../../../bin/alacritty $out/Applications/Alacritty.app/Contents/MacOS/alacritty
      ''}
    '';
  }
