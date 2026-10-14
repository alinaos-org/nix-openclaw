# Gateway recipe

The recipe [openclaw-nix](https://github.com/alinaos-org/openclaw-nix) builds the OpenClaw
gateway with (its `packages/gateway`): `packages/openclaw-gateway-source.nix` and the
files it reads, plus `scripts/gateway-build.sh` and `scripts/gateway-prebuild.sh`, which
openclaw-nix copies into the build and edits, and `packages/pnpm-11.nix`, the pnpm it
builds with.

It is upstream nix-openclaw's recipe at
[e72fe70](https://github.com/openclaw/nix-openclaw/tree/e72fe70f6d23cf2efe8a2a693f0788090af9bde0/nix)
(2026-08-04), copied file for file with the same layout, so the relative paths between the
files still hold. It is kept apart from `nix/packages` because upstream's later recipe
there (`build:package`) breaks openclaw-nix's `@openclaw/ai` step on OpenClaw 2026.10.x,
and this fork follows upstream's main for everything else.

This directory is ours: change it here when a release needs it. openclaw-nix reads only
this directory (`builtins.path`, without this README), so the gateway rebuilds when a
file here changes and never when the rest of the fork does.
