{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  buildInputs = [ (pkgs.callPackage ./packages.nix { }) ];
  shellHook = "exec ${pkgs.fish}/bin/fish";
}
