# Agent Bootstrap — CriomOS-pkgs

## Scope

The `pkgs` axis of CriomOS's 3-flake architecture. Instantiates
`nixpkgs` for one `(nixpkgs-rev, system)` tuple and applies the
overlays CriomOS's modules need.

This repo exists in its own slot so that CriomOS source edits don't
invalidate the pkgs eval cache. `import nixpkgs { ... }` is expensive;
keying it on `(nixpkgs.narHash, system.narHash, overlays-content)` —
all of which live here, decoupled from CriomOS's module tree — lets it
cache across CriomOS iteration.

## What does NOT live here

- CriomOS modules / package definitions / horizon. Those are in
  [`CriomOS`](https://github.com/LiGoldragon/CriomOS).
- The horizon projection logic. That's
  [`horizon-rs`](https://github.com/LiGoldragon/horizon-rs).
- The deploy orchestrator. That's
  [`lojix-cli`](https://github.com/LiGoldragon/lojix-cli).

## Conventions

- Jujutsu (`jj`) for all VCS. Never `git` CLI.
- Mentci three-tuple commit format.
- Overlays added here should have a comment explaining the
  *why*: which upstream issue, which consumer pulls the package,
  why a global overlay vs surgical fix. Cite issue URLs.
