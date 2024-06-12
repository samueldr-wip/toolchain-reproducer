{ pkgs }:

let
  overlays = pkgs.appendOverlays [(final: super: {
    uefiPkgs = import (final.path) {
      # This is not desirable if we want cross-compilation.
      # inherit (final.stdenv) system;
      crossSystem = {
        config = "${final.hostPlatform.parsed.cpu.name}-windows";
        rustc.config = "${final.hostPlatform.parsed.cpu.name}-unknown-uefi";
        libc = null;
        useLLVM = true;
      };
    };
  })];

  expose = pkgs: {
    inherit pkgs;
    hello-uefi = pkgs.uefiPkgs.callPackage ./hello.nix {};
  };
in
# This assumes this is built on an x86_64-linux system... *sigh*
{
  "x86_64"  = expose overlays;
  "aarch64" = expose overlays.pkgsCross.aarch64-multiplatform;
}
