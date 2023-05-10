{ rustToolchain
, cargoArgs
, unitTestArgs
, pkgs
, ...
}:

let
  cargo-ext = pkgs.callPackage ./cargo-ext.nix { inherit cargoArgs unitTestArgs; };
in
pkgs.mkShell {
  name = "dev-shell";

  nativeBuildInputs = with pkgs; [
    cargo-ext.cargo-build-all
    cargo-ext.cargo-clippy-all
    cargo-ext.cargo-doc-all
    cargo-ext.cargo-nextest-all
    cargo-ext.cargo-test-all
    cargo-ext.cargo-udeps-all
    cargo-ext.cargo-watch-all
    cargo-nextest
    cargo-udeps
    cargo-watch
    rustToolchain

    tokei

    # uncomment the following lines if you need `clang` or `protoc`
    # llvmPackages.clang
    # llvmPackages.libclang
    #
    # protobuf

    treefmt

    jq
    nixpkgs-fmt
    shfmt
    nodePackages.prettier
    shellcheck
  ];

  # uncomment the following lines if you need `clang` or `protoc`
  # PROTOC = "${pkgs.protobuf}/bin/protoc";
  # PROTOC_INCLUDE = "${pkgs.protobuf}/include";
  #
  # LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

  shellHook = ''
    export NIX_PATH="nixpkgs=${pkgs.path}"
  '';
}
