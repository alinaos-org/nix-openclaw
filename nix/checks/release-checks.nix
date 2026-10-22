# The module, lock and script checks for one package set and the release data
# it is built with: the typed config options the Home Manager module is
# evaluated with, and a runtime-plugin lock set with the OpenClaw source it was
# generated from. This flake's own checks use nix/generated's (flake.nix);
# openclaw-nix passes its pins for each release (lib.mkChecks).
#
# None of them builds OpenClaw: the module checks are evaluation-time
# assertions over the module (evaluating them is most of their cost), and the
# rest run small scripts.
{
  pkgs,
  openclawConfigOptionsFile ? ../generated/openclaw-config-options.nix,
  runtimePluginLockDir ? ../generated/openclaw-runtime-plugins,
  # { releaseTag, releaseVersion, runtimePluginVersion, rev, hash } of the
  # OpenClaw source the locks were generated from. null: nix/sources'.
  openclawSourceInfo ? null,
  # Plugin ids the lock set must keep supporting, beyond the checker's own.
  requiredRuntimePluginIds ? [ ],
}:

let
  instance =
    args:
    pkgs.callPackage ./openclaw-default-instance.nix ({ inherit openclawConfigOptionsFile; } // args);
in
{
  default-instance = instance { };
  plugin-instance = instance { includePluginChecks = true; };
  source-override-render = instance { includeSourceOverrideChecks = true; };
  runtime-environment = pkgs.callPackage ./openclaw-runtime-environment.nix {
    inherit openclawConfigOptionsFile;
  };
  workspace-materializer = pkgs.callPackage ./openclaw-workspace-materializer.nix { };
  runtime-plugin-locks = pkgs.callPackage ./openclaw-runtime-plugin-locks.nix {
    lockDir = runtimePluginLockDir;
    sourceInfo = openclawSourceInfo;
    requiredIds = requiredRuntimePluginIds;
  };
  script-tests = pkgs.callPackage ./openclaw-script-tests.nix { };
}
