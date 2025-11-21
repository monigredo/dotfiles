You are an AI coding assistant working inside my **dotfiles repo** on a Fedora dev machine.

## Context

- Host OS: **Fedora 43**, Wayland.
- WM: **Sway**.
- Home: `/home/<user>`, but you can assume `$HOME` is set correctly.
- My dotfiles repo is checked out at: `~/dotfiles`.

I manage configs with **stow**:

- After cloning, I typically run:
  ```bash
  cd ~/dotfiles
  stow shell sway waybar alacritty git env
  ```

Relevant pieces:

- **Bootstrap script**: `~/dotfiles/bootstrap-fedora-dev.sh`
  - Installs core packages and sets global git defaults.
- **Helper scripts directory in repo** (intended canonical source):
  - `~/dotfiles/shell/.local/bin/`
- **Runtime helper scripts location on system**:
  - `$HOME/.local/bin/` (in `PATH`)

Some helper scripts are already present / expected:

- `run-swayidle` – wrapper around `swayidle` (`run-swayidle [timeout_seconds]`, default 900).
- `sway-handle-lid.sh` – uses `swaymsg` + `jq` to:
  - If **no external monitor** → `swaylock -f -c 000000` then `systemctl suspend`.
  - If external monitor present → do nothing on lid close.
- `wifi-menu` – runs `alacritty -e nmtui`.
- `rofi-bluetooth` – rofi-based Bluetooth controller, expected at `~/.local/bin/rofi-bluetooth`.

At the moment:

- Some scripts live only in `$HOME/.local/bin` and **are not yet in the dotfiles repo**.
- I want the **dotfiles repo** to be the authoritative source for *all* my helper scripts.
- Goal: be able to grab any machine, clone `~/dotfiles`, run `bootstrap-fedora-dev.sh`, and have:
  - All helper scripts installed into `~/.local/bin` correctly,
  - With proper permissions,
  - Without copying anything manually from my current laptop.

## Your tasks

You are working **inside** the `~/dotfiles` repo. Assume you have access to all files in the repo, but *not* to `$HOME/.local/bin` outside the repo.

Do the following:

1. **Normalize helper scripts into the repo**

   - Inspect `shell/.local/bin/` (and other `*/.local/bin/` paths if present).
   - Ensure that the following scripts exist in the repo under `shell/.local/bin/`:
     - `run-swayidle`
     - `sway-handle-lid.sh`
     - `wifi-menu`
     - `rofi-bluetooth` (if I’ve already added it; if not, leave a clear TODO comment in the bootstrap script and do not invent its contents).
   - For any helper script in the repo:
     - Ensure it has:
       - A correct shebang (`#!/usr/bin/env bash` unless there’s a strong reason otherwise).
       - Executable permission expected on the target system (we’ll enforce this via the bootstrap script).
     - Don’t change the behavior of existing working scripts unless strictly necessary.

2. **Make the bootstrap script install helper scripts cleanly**

   - Open `bootstrap-fedora-dev.sh`.
   - Add logic so that, after package installs and before finishing, the script:
     1. Ensures `$HOME/.local/bin` exists:
        ```bash
        mkdir -p "$HOME/.local/bin"
        ```
     2. Ensures that all helper scripts from `shell/.local/bin` in the repo are installed into `$HOME/.local/bin`.
        - **Preferred approach**: use stow to create symlinks, not copies, so the scripts remain versioned via dotfiles.
        - If stow is already being used for the `shell` package, verify that `shell/.local/bin/*` ends up mapped into `$HOME/.local/bin`. If necessary:
          - Adjust the directory structure under `shell/` so that stow will produce:
            - `shell/.local/bin/run-swayidle` → `$HOME/.local/bin/run-swayidle`
            - etc.
          - Or add an explicit `stow shell` step in the bootstrap script after ensuring stow is installed.
     3. Make sure the bootstrap script is **idempotent**:
        - Re-running it should not break or duplicate anything.
        - Symlinks/scripts should be overwritten safely if needed.

   - If stow alone can handle all the `.local/bin` mapping (which is preferred), keep the logic simple:
     - Ensure `stow` is installed early in the script.
     - Run the appropriate `stow` commands so `.local/bin` scripts appear where Sway/Waybar expect them.

3. **Permissions and safety checks**

   - Add a small helper section in `bootstrap-fedora-dev.sh` that:
     - Verifies that the helper scripts that are supposed to exist actually do after setup, e.g. something like:
       ```bash
       for bin in run-swayidle sway-handle-lid.sh wifi-menu; do
         if [ ! -x "$HOME/.local/bin/$bin" ]; then
           echo "WARNING: $HOME/.local/bin/$bin is missing or not executable" >&2
         fi
       done
       ```
     - Don’t hard-fail the script if one of them is missing; just warn, because some scripts (like lid handlers) may be irrelevant inside VMs.

4. **Keep behavior consistent with my existing Sway/Waybar setup**

   - Do **not** change any of the existing Sway keybindings, `exec` commands, or paths that expect:
     - `~/.local/bin/run-swayidle`
     - `~/.local/bin/sway-handle-lid.sh`
     - `~/.local/bin/wifi-menu`
     - `~/.local/bin/rofi-bluetooth`
   - The only allowed change is to make sure those paths are satisfied by installing/symlinking scripts from the dotfiles repo.

5. **Produce a clear diff**

   - Show the final result as a unified diff (git-style patch) covering all changes:
     - Modifications to `bootstrap-fedora-dev.sh`.
     - Any new or modified scripts under `shell/.local/bin/`.
   - Do not include unrelated changes.

## Constraints / style

- Don’t refactor the bootstrap script aggressively; keep it readable and minimal.
- Prefer symlinks via `stow` over manual copying so that future changes to scripts in the repo are reflected on the system.
- Keep everything POSIX-ish shell-compatible (`bash` is available, but don’t rely on obscure bashisms when not needed).

Now:
1. Inspect the repo structure relevant to `.local/bin` and the bootstrap script.
2. Propose the necessary file additions/adjustments under `shell/.local/bin/`.
3. Update `bootstrap-fedora-dev.sh` accordingly.
4. Output the unified diff with all changes.
