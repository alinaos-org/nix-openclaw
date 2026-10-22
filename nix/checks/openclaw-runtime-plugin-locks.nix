{
  lib,
  stdenvNoCC,
  nodejs_24,
  callPackage,
  # The lock set to check: a directory as update-openclaw-runtime-plugin-locks.mjs
  # writes it (default.nix, one .nix per plugin, package-lock files, report.json).
  lockDir ? ../generated/openclaw-runtime-plugins,
  # The OpenClaw source the locks were generated from: releaseTag,
  # releaseVersion, runtimePluginVersion, rev and hash. null: nix/sources'.
  sourceInfo ? null,
  # Plugin ids the lock set must keep supporting, beyond the checker's own
  # (slack, discord, brave, diagnostics-prometheus and acpx): the ones a
  # consumer's hosts load.
  requiredIds ? [ ],
}:

let
  scriptsDir = ../scripts;
  locks = import (lockDir + "/default.nix");
  locksJson = builtins.toFile "openclaw-runtime-plugin-locks.json" (builtins.toJSON locks);
  # The checker reads the fields as `name = "value";` lines.
  sourceInfoFile =
    if sourceInfo == null then
      ../sources/openclaw-source.nix
    else
      builtins.toFile "openclaw-source-info.nix" (
        lib.generators.toPretty { } {
          inherit (sourceInfo)
            releaseTag
            releaseVersion
            runtimePluginVersion
            rev
            hash
            ;
        }
      );
  report = lib.importJSON (lockDir + "/report.json");
  supportedIds = map (row: row.id) (report.supported or [ ]);
  skippedAs =
    id:
    let
      rows = lib.filter (row: (row.id or null) == id) (report.skipped or [ ]);
    in
    if rows == [ ] then
      "in no catalog"
    else
      "skipped as ${(builtins.head rows).reason or "?"} (${(builtins.head rows).detail or ""})";
  missingRequired = map (id: "${id}: ${skippedAs id}") (
    lib.filter (id: !(lib.elem id supportedIds)) requiredIds
  );
in
stdenvNoCC.mkDerivation {
  pname = "openclaw-runtime-plugin-locks";
  version = report.openclawVersion or "1";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    nodejs_24
    (callPackage ../packages/node-semver.nix { })
  ];

  env = {
    OPENCLAW_RUNTIME_PLUGIN_LOCK_DIR = "${lockDir}";
    OPENCLAW_RUNTIME_PLUGIN_LOCKS_JSON = "${locksJson}";
    OPENCLAW_SOURCE_INFO_PATH = "${sourceInfoFile}";
    # Pure CI evaluation cannot opt into local release-evidence overrides.
    OPENCLAW_RUNTIME_PLUGIN_ALLOW_EVIDENCE_OVERRIDE = builtins.getEnv "OPENCLAW_RUNTIME_PLUGIN_ALLOW_EVIDENCE_OVERRIDE";
    OPENCLAW_REQUIRED_RUNTIME_PLUGINS_MISSING = lib.concatStringsSep "; " missingRequired;
  };

  doCheck = true;
  checkPhase = ''
    if [ -n "$OPENCLAW_REQUIRED_RUNTIME_PLUGINS_MISSING" ]; then
      echo "required runtime plugins the lock set no longer supports: $OPENCLAW_REQUIRED_RUNTIME_PLUGINS_MISSING" >&2
      exit 1
    fi
    ${nodejs_24}/bin/node ${scriptsDir}/check-openclaw-runtime-plugin-locks.mjs
  '';
  installPhase = "${../scripts/empty-install.sh}";

  meta.description = "Validate an OpenClaw runtime plugin lock set and its support report";
}
