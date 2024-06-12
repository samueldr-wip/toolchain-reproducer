{ rust
, rustPlatform
, clippy
, rustfmt
, stdenv
, lib
, runCommand
#, enableFmt ? false
#, enableLint ? false
#, fatVariant ? false
}:

let
  cargo_toml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
in
rustPlatform.buildRustPackage {
  pname = cargo_toml.package.name;
  version = cargo_toml.package.version;
  src = lib.cleanSource ./.;
  cargoHash = "";
  meta = {
    platforms = [
      # *sigh*
      "x86_64-windows"
      "aarch64-windows"
      "i686-windows"
    ];
  };
}
