{
  stdenvNoCC,
  nodejs_24,
  git,
  jq,
  nix,
  callPackage,
}:

# Every node --test file in nix/scripts (the plugin builder, lock generator and
# checker, gateway build helpers), on the Node, Git, jq and semver CLI they
# were written against (the scripts under test call jq; upstream's CI runners
# had it preinstalled). The tests write next to their fixtures, so they run
# from a copy of the directory.
stdenvNoCC.mkDerivation {
  pname = "openclaw-script-tests";
  version = "1";

  src = ../scripts;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    nodejs_24
    git
    jq
    # nix-string.test.mjs evaluates its Nix literals with Nix itself; the
    # sandbox has no store to open, and evaluation needs none.
    nix
    (callPackage ../packages/node-semver.nix { })
  ];

  env.NIX_CONFIG = "store = dummy://";

  doCheck = true;
  checkPhase = ''
    export HOME=$TMPDIR
    node --test ./*.test.mjs ./*.test.js
  '';
  installPhase = "${../scripts/empty-install.sh}";

  meta.description = "Run the nix/scripts node tests";
}
