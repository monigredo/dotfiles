# Bootstrap Evolution Roadmap

## Summary

This repo currently uses `bootstrap-fedora-dev.sh` as a practical Fedora setup script: install packages, configure user defaults, link helpers, and verify the desktop/dev environment. That is still the right center of gravity.

The long-term goal is to make the bootstrap flow safe and useful to rerun on personal laptops and users that may have drifted over time, without turning the dotfiles repo into a full configuration management framework too early.

The preferred path is incremental:

1. Keep Bash as the main implementation while the workflow is Fedora-first and mostly package/config orchestration.
2. Make reruns explicit and safe.
3. Add minimal user-local state only where it removes repeated prompts or improves reporting.
4. Introduce a small Python orchestrator only when profiles, platforms, or state make Bash noticeably awkward.

## Guiding Principles

- Keep changes small, reviewable, and reversible.
- Treat repo files as the source of truth; treat local state as a convenience cache.
- Prefer idempotent operations over one-shot setup assumptions.
- Keep fresh install and existing-machine sync flows close together, but make risky actions explicit.
- Do not automatically remove packages or rewrite personal data unless the user asks.
- Keep Fedora as the primary platform until another platform has a real use case.
- Avoid bootstrap dependencies that are not already present on a minimal system.

## Phase 1: Rerunnable Bash Bootstrap

Keep `bootstrap-fedora-dev.sh` as the main entrypoint, but make its contract clearer:

- Running bootstrap should converge the current user/machine toward the repo's desired baseline.
- Package installs, helper links, git defaults, font setup, and command checks should remain safe to rerun.
- System updates should be explicit or controllable instead of only being an unconditional first step.

Candidate flags:

```bash
./bootstrap-fedora-dev.sh
./bootstrap-fedora-dev.sh --update-system
./bootstrap-fedora-dev.sh --no-update-system
./bootstrap-fedora-dev.sh --non-interactive
./bootstrap-fedora-dev.sh --reset-bootstrap-state
```

Recommended behavior:

- `--update-system`: run `sudo dnf update -y`.
- `--no-update-system`: skip system update and only install/verify the baseline.
- No update flag: keep current interactive behavior initially, but eventually prompt before updating when a TTY is available.
- `--non-interactive`: skip prompts and preserve existing choices.
- `--reset-bootstrap-state`: delete remembered bootstrap choices before continuing.

The existing fresh-machine flow should continue to work:

```bash
cd ~/dotfiles
./bootstrap-fedora-dev.sh
./stow-clean-restow.sh
```

The existing-machine sync flow should become documented and intentional:

```bash
cd ~/dotfiles
git pull --ff-only
./bootstrap-fedora-dev.sh --update-system
./stow-clean-restow.sh
```

## Phase 2: Minimal Local State

Add local state only after the rerunnable bootstrap flags exist.

Preferred path:

```text
~/.local/state/dotfiles-bootstrap/state.env
```

Initial state fields:

```bash
BOOTSTRAP_SCHEMA_VERSION=1
LAST_BOOTSTRAP_DATE=2026-06-09
LAST_BOOTSTRAP_COMMIT=abc1234
LAST_SYSTEM_UPDATE_DATE=2026-06-09
INSTALL_VSCODE_DEV_STACK=yes
INSTALL_OBSIDIAN=no
INSTALL_CODEX=yes
```

State rules:

- Use plain `KEY=value` so Bash can read it without a parser.
- Keep values simple: lowercase `yes`/`no`, dates as `YYYY-MM-DD`, commit as short or full git hash.
- Do not store secrets.
- Do not track every installed package.
- Do not use state as proof that a tool exists; still verify commands/files directly.
- If state is missing or malformed, warn and continue with safe defaults.

Useful outcomes:

- Avoid asking the same optional install questions on every rerun.
- Report when the machine was last bootstrapped and from which commit.
- Skip frequent system updates later if a recency policy is added.
- Support simple future migrations if helper paths or config locations change.

## Phase 3: Python Orchestrator When Needed

Do not rewrite the bootstrap script immediately.

Introduce a small Python CLI only when Bash starts carrying too much of this:

- host or user profiles;
- multiple supported platforms;
- structured manifests;
- non-trivial state handling;
- dry-run/status output;
- repeated command orchestration logic.

Possible future shape:

```text
bootstrap-fedora-dev.sh
stow-clean-restow.sh
scripts/
  dotctl
config/
  dev-versions.sh
  packages.fedora.toml
  packages.macos.toml
  packages.wsl.toml
```

Possible commands:

```bash
scripts/dotctl sync
scripts/dotctl doctor
scripts/dotctl restow
scripts/dotctl update-system
scripts/dotctl status
```

Migration rule:

- Keep `bootstrap-fedora-dev.sh` as a compatibility wrapper if `scripts/dotctl` becomes the real orchestrator.
- Do not require Node, Go, or Rust just to bootstrap a new machine.
- Python is the preferred orchestrator language because it is readable, broadly available, and good enough for state, manifests, and command execution.

## Phase 4: Multiplatform Direction

Fedora remains the primary supported platform.

If macOS or WSL support becomes real, add platform-specific modules or manifests rather than growing large conditional blocks in the Fedora script.

Potential split:

- Fedora: `dnf`, Flatpak, Sway/Hyprland/Niri, Wayland helpers.
- macOS: Homebrew, shell/dev tools, terminal/editor settings.
- WSL: apt/dnf depending on distro, shell/dev tools, no desktop session setup by default.

Keep shared behavior small:

- stow shell/editor/terminal configs where paths match;
- configure git defaults;
- create development directories;
- verify expected commands;
- report missing manual steps.

## Deferred Ideas

These are intentionally not part of the near-term plan:

- Semantic versioning for the dotfiles repo.
- A migration framework.
- Automatic package removal.
- Tracking every installed package.
- A daemon, background service, or scheduled updater.
- A full cross-platform abstraction before a second platform is actively used.

## Acceptance Criteria

This roadmap is successful if future changes can be judged against it:

- Simple rerun safety improvements should stay in Bash.
- State should remain small and user-local.
- Python should appear only after real complexity justifies it.
- Multiplatform work should not make the Fedora path harder to read or maintain.
