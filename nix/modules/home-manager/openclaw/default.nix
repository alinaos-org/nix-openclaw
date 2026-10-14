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
  # option would recurse). Hosts that build another release set it to that
  # release's generate-config-options.ts output; null keeps nix/generated's.
  config._module.args.openclawConfigOptionsFile = lib.mkDefault null;
}
