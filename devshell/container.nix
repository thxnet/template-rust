{ name
, version
, dockerTools
, template-rust
, buildEnv
, ...
}:

dockerTools.buildImage {
  inherit name;
  tag = "v${version}";

  copyToRoot = buildEnv {
    name = "image-root";
    paths = [ template-rust ];
    pathsToLink = [ "/bin" ];
  };

  config = {
    Entrypoint = [ "${template-rust}/bin/template-rust" ];
  };
}
