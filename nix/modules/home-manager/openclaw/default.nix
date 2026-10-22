{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.mkRemovedOptionModule [
      "programs"
      "openclaw"
      "firstParty"
    ] "Use programs.openclaw.bundledPlugins.<name>.enable/config.")
    (lib.mkRemovedOptionModule [
      "programs"
      "openclaw"
      "plugins"
    ] "Use programs.openclaw.customPlugins.")
    ./options.nix
    ./config.nix
  ];
  # The typed config options file for the OpenClaw release a host runs, as a
  # module argument because the option declarations themselves need it (an
  # option would recurse): that release's generate-config-options.ts output.
  # openclaw-nix provides one per release. Left null, evaluation stops and says
  # so; nix/generated's options are not a fallback.
  config._module.args.openclawConfigOptionsFile = lib.mkDefault null;
}
