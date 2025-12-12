# Repository Guidelines

## Project Structure & Module Organization
- Root scripts: `bootstrap-fedora-dev.sh` (Fedora + Sway bootstrap) and `stow-clean-restow.sh` (remove conflicts then restow).
- Stow packages: `shell/`, `sway/`, `waybar/`, `alacritty/`, `git/`, `env/` → mapped to `$HOME`.
- Helper scripts reside in `shell/.local/bin/` and are symlinked to `~/.local/bin` (`run-swayidle`, `sway-handle-lid.sh`, `wifi-menu`, `mullvad-waybar`, `protonvpn-waybar`).
- Docs: `README.md` (full), `README-quickstart.md` (concise), `dotfiles-helper-bootstrap-prompt.md` (AI task context), `AGENTS.md` (this doc).

## Build, Test, and Development Commands
- Bootstrap a machine (installs packages, fonts, helper scripts, rofi-bluetooth):  
  ```bash
  ./bootstrap-fedora-dev.sh
  ```
- Restow cleanly (removes conflicting files first, then stows common packages):  
  ```bash
  ./stow-clean-restow.sh                # defaults to shell sway waybar alacritty git env
  ./stow-clean-restow.sh shell sway     # choose packages
  ```
- Standard stow (if you do it manually): `stow shell sway waybar alacritty git env`

## Coding Style & Naming Conventions
- Shell scripts: `#!/usr/bin/env bash`, `set -euo pipefail`; prefer simple POSIX-friendly constructs.
- File naming: use kebab-case for helper scripts; keep helper paths under `shell/.local/bin/`.
- Keep configs ASCII; minimal comments unless clarity is needed.

## Testing Guidelines
- No automated test suite. Validate manually:
  - Run bootstrap on a fresh-ish environment.
  - Confirm helper symlinks exist: `ls -l ~/.local/bin/run-swayidle ...`.
  - For sway/waybar changes, reload in a session and sanity-check keybindings/exec paths.

## Commit & Pull Request Guidelines
- Commits: concise imperative subject (e.g., "restow helpers via script", "add sway lid handler"); group related changes.
- PRs (or change descriptions): explain motivation, list key changes, note manual test steps (e.g., bootstrap run, stow run), and call out breaking changes or manual follow-ups.

## Security & Configuration Tips
- Never run destructive commands (`git reset --hard`, `rm -rf ~`) in automation; prefer stow-clean-restow for conflict handling.
- Network installs are confined to expected downloads in bootstrap (dnf, pipx, rofi-bluetooth clone); avoid adding new network calls without need.

## Agent Notes
- Keep `AGENTS.md` current when workflows, scripts, or package lists change (especially bootstrap/stow logic or helper script locations).
- Document new helper scripts under `shell/.local/bin/` (e.g., `mullvad-waybar` for the Waybar Mullvad toggle) and ensure bootstrap/stow steps reflect them.***
- `run-swayidle` locks after its timeout and powers displays off 30s later; update docs if timings or behavior change.
- Codex CLI binary install is optional via bootstrap prompt calling `scripts/install-codex-binary.sh` (downloads latest GitHub release to `~/.local/bin/codex`).***
