{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nmattia/naersk";
    mozillapkgs = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, naersk, mozillapkgs, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";

        # Get a specific rust version
        mozilla = pkgs.callPackage (mozillapkgs + "/package-set.nix") { };
        chanspec = {
          date = "2020-07-30";
          channel = "nightly";
          sha256 = "Ila7LSJGRAc4dqODJb5qnN0JxCKeCILv0xA3x/qQ820="; # set zeros after modifying channel or date
        };

        rustChannel = mozilla.rustChannelOf chanspec;
        rust = rustChannel.rust;
        rust-src = rustChannel.rust-src;

        naersk-lib = naersk.lib."${system}".override {
          cargo = rust;
          rustc = rust;
        };

      in
      rec {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            rust
            rust-src
            pkgs.rust-analyzer
            pkgs.rustfmt
            pkgs.cargo
            pkgs.cargo-watch
          ];
          RUST_SRC_PATH = "${rust-src}/lib/rustlib/src/rust/library";
          RUST_LOG = "info";
          RUST_BACKTRACE = 1;
        };
      });
}
