{
  description = "Rust template of THXLAB";
  # NOTE: replace `template-rust` with your project name.

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fenix, crane }:
    let
      name = "template-rust";
      version = "0.0.0";
    in
    (flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
              fenix.overlays.default
            ];
          };

          rustToolchain = fenix.packages.${system}.fromToolchainFile {
            file = ./rust-toolchain.toml;
            sha256 = "sha256-NtTO8TcANetJgeDCGOWaUZBqQn+kQH7rzYRgf8W9T+o=";
          };

          rustPlatform = pkgs.makeRustPlatform {
            cargo = rustToolchain;
            rustc = rustToolchain;
          };

          craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

          cargoArgs = [
            "--workspace"
            "--bins"
            "--examples"
            "--tests"
            "--benches"
            "--all-targets"
          ];

          unitTestArgs = [
            "--workspace"
          ];

          src = craneLib.cleanCargoSource (craneLib.path ./.);
          commonArgs = {
            inherit src;

            # uncomment the following lines if you need `clang` or `protoc`
            # nativeBuildInputs = with pkgs; [
            #   llvmPackages.clang
            #   llvmPackages.libclang
            # ];

            # PROTOC = "${pkgs.protobuf}/bin/protoc";
            # PROTOC_INCLUDE = "${pkgs.protobuf}/include";
            #
            # LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          };
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        in
        {
          formatter = pkgs.treefmt;

          devShells.default = pkgs.callPackage ./devshell {
            inherit rustToolchain cargoArgs unitTestArgs;
          };

          packages = rec {
            default = template-rust;
            template-rust = pkgs.callPackage ./devshell/package.nix {
              inherit name version rustPlatform;
            };
            container = pkgs.callPackage ./devshell/container.nix {
              inherit name version template-rust;
            };
          };

          checks = {
            format = pkgs.callPackage ./devshell/format.nix { };

            rust-build = craneLib.cargoBuild (commonArgs // {
              inherit cargoArtifacts;
            });
            rust-format = craneLib.cargoFmt { inherit src; };
            rust-clippy = craneLib.cargoClippy (commonArgs // {
              inherit cargoArtifacts;
              cargoClippyExtraArgs = pkgs.lib.strings.concatMapStrings (x: x + " ") cargoArgs;
            });
            rust-nextest = craneLib.cargoNextest (commonArgs // {
              inherit cargoArtifacts;
              partitions = 1;
              partitionType = "count";
            });
          };
        })) // {
      overlays.default = final: prev: { };
    };
}