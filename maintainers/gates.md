# Gates

This repository has no CI of its own. openclaw-nix consumes its `openclaw-nix`
branch, and openclaw-nix's CI runs these checks against every release it builds:
`lib.mkChecks` (`nix/checks/release-checks.nix`) with openclaw-nix's package set,
the release's typed config options and its runtime-plugin lock set
(`checks.<system>.nix-openclaw-*` there). Verify a change here the same way before
it lands: from an openclaw-nix checkout, build those checks with
`--override-input nix-openclaw path:<this worktree>`.

## The release checks

- `default-instance`, `plugin-instance`, `source-override-render`: evaluation-time
  assertions over the Home Manager module (`nix/checks/default-instance`).
- `runtime-environment`, `workspace-materializer`: the module's gateway
  environment wrapper and workspace materializer.
- `runtime-plugin-locks`: `nix/scripts/check-openclaw-runtime-plugin-locks.mjs`
  over a lock set and the OpenClaw source it was generated from, plus the plugin
  ids a consumer requires to stay supported.
- `script-tests`: every `node --test` file in `nix/scripts`, on the pinned Node 24,
  Git, jq and semver CLI.

This flake's own `checks.<system>` run the same set on `nix/generated` (the last
release this repository pinned), beside the package, gateway, QMD and activation
checks, which build OpenClaw.

## Runtime plugin lock checks

`nix develop --command node nix/scripts/update-openclaw-runtime-plugin-locks.mjs --check`
compares regenerated artifacts without creating or changing the generated directory.
Use no argument to write updates. Unknown or repeated flags fail before Nix
runs; `--help` prints usage without fetching artifacts.

Plugin compatibility checks use the pinned `node-semver` tool from `nix develop`
(the `runtime-plugin-locks` and `script-tests` checks supply it too). Peer ranges
use npm syntax, including wildcards, caret, tilde and OR ranges. Plugin API ranges
follow upstream OpenClaw: comparator intersections only, bare major.minor as a
minimum, and release-suffix normalization. Minimum host versions retain numeric
correction ordering after stable releases; legacy bare minimums remain accepted.
Missing tooling aborts generation before processing artifacts.
