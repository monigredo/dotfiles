# Repository Guidelines

## Project Structure & Module Organization
- Root scripts: `bootstrap-fedora-dev.sh` (Fedora + Sway/Hyprland/Niri bootstrap) and `stow-clean-restow.sh` (remove conflicts then restow).
- Stow packages: `shell/`, `sway/`, `waybar/`, `ghostty/`, `tmux/`, `env/`, `hyprland/`, `niri/` → mapped to `$HOME`.
- Helper scripts reside in `shell/.local/bin/` and are symlinked to `~/.local/bin` (`dev-terminal`, `run-swayidle`, `run-niri-swayidle`, `sway-handle-lid.sh`, `niri-handle-lid.sh`, `sway-move-workspace-next-output`, `hypr-handle-lid.sh`, `hypr-kblayout-waybar`, `hypr-move-workspace-next-output`, `wifi-menu`, `obsidian-launch`, `theme-toggle`).
- Preferred Node, npm, Python, Java, Go, Kotlin, VS Code package targets, fallback candidates, and VS Code extension IDs live in `config/dev-versions.sh`.
- Docs: `README.md` (full), `README-quickstart.md` (concise), `NIRI-CHEATSHEET.md`, `TMUX-CHEATSHEET.md`, `dotfiles-helper-bootstrap-prompt.md` (AI task context), `AGENTS.md` (this doc).

## Build, Test, and Development Commands
- Bootstrap a machine (installs packages, sets up zsh as the default login shell when confirmed, fonts, helper scripts, rofi-bluetooth):  
  ```bash
  ./bootstrap-fedora-dev.sh
  ```
  Includes core CLI tooling (including `eza` for interactive `l`/`la`/`ll`/`lg`/`lll` aliases), shared Wayland desktop support (`waybar`, `rofi-wayland`, `grim`, `slurp`, `brightnessctl`, `playerctl`, `pavucontrol`, `wireplumber`, `mako`, `lxqt-policykit`, `xdg-desktop-portal`, `xdg-desktop-portal-gtk`, `nm-connection-editor`), the current Sway runtime (`sway`, `swayidle`, `swaylock`), the default Niri runtime (`niri`, `xwayland-satellite`, `xdg-desktop-portal-gnome`), plus the optional Hyprland runtime used by the repo (`hyprland`, `hypridle`, `hyprlock`, `qt6-qtwayland`, `xdg-desktop-portal-hyprland`).
  Java packages are resolved dynamically: bootstrap prefers Java 21 when available, falls back to Fedora's latest/default OpenJDK package set, and skips Java if no supported OpenJDK packages are available in enabled repositories.
  Obsidian is optional via a bootstrap Flatpak prompt (`md.obsidian.Obsidian` from Flathub); vault contents stay outside dotfiles.
  VS Code is optional via a bootstrap prompt: bootstrap adds Microsoft's Fedora yum repo, installs stable `code`, installs configured Marketplace extensions, and installs supporting Node/npm/pnpm, Python (`pip`, `virtualenv`, `pytest`, `ruff`, `uv`), Go, Java/Kotlin, container, YAML, and TOML tooling. Preferred targets come from `config/dev-versions.sh`; fallbacks must be highly visible immediately and repeated in the final bootstrap summary.
  Ghostty is the default terminal; bootstrap prompts to enable the unofficial `scottames/ghostty` COPR if Ghostty is not available in enabled standard Fedora repositories.
  Fedora 43 Hyprland support is currently experimental and may rely on the `solopasha/hyprland` COPR; optional packages such as `hyprland-qtutils` are not treated as bootstrap requirements because they can lag behind Fedora Qt updates.
- Restow cleanly (removes conflicting files first, then stows common packages):  
  ```bash
  ./stow-clean-restow.sh                # defaults to shell sway waybar ghostty tmux env hyprland niri
  ./stow-clean-restow.sh shell sway     # choose packages
  ```
- Standard stow (if you do it manually): `stow shell sway waybar ghostty tmux env hyprland niri`

## Coding Style & Naming Conventions
- Shell scripts: `#!/usr/bin/env bash`, `set -euo pipefail`; prefer simple POSIX-friendly constructs.
- Interactive shell defaults live in `shell/.zshrc` and `shell/.config/zsh/*.zsh`; keep bash-only shell hooks out of those files.
- File naming: use kebab-case for helper scripts; keep helper paths under `shell/.local/bin/`.
- Keep configs ASCII; minimal comments unless clarity is needed.

## Testing Guidelines
- No automated test suite. Validate manually:
  - Run bootstrap on a fresh-ish environment.
  - Confirm helper symlinks exist: `ls -l ~/.local/bin/run-swayidle ~/.local/bin/run-niri-swayidle ~/.local/bin/sway-handle-lid.sh ~/.local/bin/niri-handle-lid.sh`.
  - For Sway or Waybar changes, reload in a session and sanity-check keybindings/exec paths.
  - For Niri changes, validate on a real `Niri` GDM login and confirm `~/.config/niri/config.kdl` plus `~/.config/waybar-niri/` are active in-session.

## Commit & Pull Request Guidelines
- Commits: concise imperative subject (e.g., "restow helpers via script", "add sway lid handler"); group related changes.
- PRs (or change descriptions): explain motivation, list key changes, note manual test steps (e.g., bootstrap run, stow run), and call out breaking changes or manual follow-ups.

## Security & Configuration Tips
- Never run destructive commands (`git reset --hard`, `rm -rf ~`) in automation; prefer stow-clean-restow for conflict handling.
- Network installs are confined to expected downloads in bootstrap (dnf, pipx, rofi-bluetooth clone, optional Flathub Obsidian install, optional Microsoft VS Code repo/package, optional VS Code Marketplace extensions, optional SDKMAN/Kotlin install); avoid adding new network calls without need.

## Agent Notes
- Keep `AGENTS.md` current when workflows, scripts, or package lists change (especially bootstrap/stow logic, Hyprland/Sway/Niri package lists, or helper script locations).
- Keep `config/dev-versions.sh` as the single update point for preferred dev tool targets, fallback candidates, SDKMAN candidates, and VS Code extension IDs.
- Document new helper scripts under `shell/.local/bin/` (e.g., `sway-move-workspace-next-output` for moving the current workspace to the next active output) and ensure bootstrap/stow steps reflect them.***
- `run-swayidle` locks after its timeout and powers displays off 30s later; update docs if timings or behavior change.
- Codex CLI binary install is optional via bootstrap prompt calling `scripts/install-codex-binary.sh` (downloads latest GitHub release to `~/.local/bin/codex`).***
