{ name
, version
, lib
, rustPlatform
  # uncomment the following lines if you need `clang` or `protoc`
  # , llvmPackages
  # , protobuf
}:

rustPlatform.buildRustPackage {
  pname = name;
  inherit version;


  doCheck = false;

  src = lib.cleanSource ./..;

  cargoLock = {
    lockFile = ../Cargo.lock;
  };

  # uncomment the following lines if you need `clang` or `protoc`
  # nativeBuildInputs = [
  #   llvmPackages.clang
  #   llvmPackages.libclang
  # ];


  # PROTOC = "${protobuf}/bin/protoc";
  # PROTOC_INCLUDE = "${protobuf}/include";

  # LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
}
