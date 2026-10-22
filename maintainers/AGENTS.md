# Maintainer Agent Guide

This directory is public maintainer guidance for agents working on `nix-openclaw`.
It is not consumer setup documentation and must not contain private deployment state.

## Boundaries

- Keep consumer onboarding in `README.md`, templates, and module docs.
- Keep private deployments, bots, hosts, local worktrees, tokens, and personal automation details out of this repo.
- If a private deployment exposes a public packaging bug, fix the public package here and keep deployment-specific repair elsewhere.
- Treat `README.md` as the product direction source of truth.

## Read Order

1. `packaging.md` for Nix-owned package invariants.
2. `gates.md` for verification: which checks run, and where.
3. Root `AGENTS.md` for repo-wide rules.

## Maintainer Workflow

- openclaw-nix consumes the `openclaw-nix` branch; changes land there.
- For multi-issue work, commit one issue at a time, and verify each with openclaw-nix's checks (`gates.md`) before it lands.
- Do not leave completed maintainer work parked on an agent branch.
- No force push. No weakening package checks just to get green.
