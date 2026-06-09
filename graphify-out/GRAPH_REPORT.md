# Graph Report - gotfiles  (2026-06-09)

## Corpus Check
- 44 files · ~21,032 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 230 nodes · 238 edges · 32 communities (23 shown, 9 thin omitted)
- Extraction: 88% EXTRACTED · 12% INFERRED · 0% AMBIGUOUS · INFERRED: 29 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `40f40cf4`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Bootstrap Dev Stack|Bootstrap Dev Stack]]
- [[_COMMUNITY_Graphify Workflow|Graphify Workflow]]
- [[_COMMUNITY_Dotfiles Stow Docs|Dotfiles Stow Docs]]
- [[_COMMUNITY_Waybar CPU Helpers|Waybar CPU Helpers]]
- [[_COMMUNITY_Node Installer|Node Installer]]
- [[_COMMUNITY_Dev Versions Config|Dev Versions Config]]
- [[_COMMUNITY_Tmux Terminal Helpers|Tmux Terminal Helpers]]
- [[_COMMUNITY_Lid Handler Scripts|Lid Handler Scripts]]
- [[_COMMUNITY_Theme Toggle|Theme Toggle]]
- [[_COMMUNITY_Codex Hooks|Codex Hooks]]
- [[_COMMUNITY_Keyboard Layout Helpers|Keyboard Layout Helpers]]
- [[_COMMUNITY_Workspace Output Helpers|Workspace Output Helpers]]
- [[_COMMUNITY_Swayidle Runners|Swayidle Runners]]
- [[_COMMUNITY_Dev Versions Script|Dev Versions Script]]
- [[_COMMUNITY_Obsidian Launcher|Obsidian Launcher]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]

## God Nodes (most connected - your core abstractions)
1. `Repository Guidelines` - 14 edges
2. `Fedora + Sway/Hyprland/Niri Dev Dotfiles` - 14 edges
3. `What You Must Do When Invoked` - 11 edges
4. `/graphify` - 10 edges
5. `Niri Test Checklist` - 10 edges
6. `Fedora + Sway/Hyprland/Niri dotfiles – Quickstart for a NEW user` - 8 edges
7. `tmux Shortcut Cheat Sheet` - 8 edges
8. `Graphify Pipeline` - 8 edges
9. `install_full_vscode_dev_stack()` - 7 edges
10. `graphify reference: extra exports and benchmark` - 7 edges

## Surprising Connections (you probably didn't know these)
- `install_vscode_package()` --implements--> `VS Code Dev Stack`  [INFERRED]
  bootstrap-fedora-dev.sh → README.md
- `Repository Guidelines` --references--> `Preferred Development Tool Targets`  [EXTRACTED]
  AGENTS.md → config/dev-versions.sh
- `Dev Versions Single Update Point` --rationale_for--> `Preferred Development Tool Targets`  [EXTRACTED]
  AGENTS.md → config/dev-versions.sh
- `Node Install` --implements--> `VS Code Dev Stack`  [INFERRED]
  scripts/install-node.sh → README.md
- `New User Bootstrap Quickstart` --semantically_similar_to--> `Niri Test Flow`  [INFERRED] [semantically similar]
  README-quickstart.md → NIRI-TEST-CHECKLIST.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Fedora Wayland Bootstrap Flow** — readme_fedora_wayland_dotfiles, readme_quickstart_new_user_bootstrap, bootstrap_fedora_dev_bootstrap, stow_clean_restow_restow, niri_test_checklist_niri_test_flow [INFERRED 0.85]
- **Centralized Dev Tool Configuration** — agents_dev_versions_single_update_point, dev_versions_tool_targets, bootstrap_fedora_dev_dev_versions_file, bootstrap_fedora_dev_install_full_vscode_dev_stack, scripts_install_node_node_install [INFERRED 0.95]
- **Graphify Operational Modes** — graphify_skill_graphify_pipeline, references_query_query_path_explain, references_update_incremental_update, references_add_watch_add_url_watch_folder, references_exports_extra_exports, references_github_and_merge_github_merge, references_transcribe_video_audio_transcription [EXTRACTED 1.00]
- **Wayland Compositor Laptop Lid And Output Helpers** — bin_hypr_handle_lid_script, bin_niri_handle_lid_script, bin_sway_handle_lid_script, bin_hypr_move_workspace_next_output_script, bin_sway_move_workspace_next_output_script [INFERRED 0.85]
- **Tmux Fzf Navigation Helpers** — bin_tmux_fzf_pane_switch_script, bin_tmux_fzf_session_switch_script, bin_tmux_fzf_window_switch_script, bin_tmux_sessionizer_script [INFERRED 0.85]
- **Waybar Status Helpers** — bin_hypr_kblayout_waybar_script, bin_sway_kblayout_waybar_script, bin_waybar_cpu_graph_script, bin_waybar_cpu_simple_script, bin_waybar_cpu_test_script [INFERRED 0.75]

## Communities (32 total, 9 thin omitted)

### Community 0 - "Bootstrap Dev Stack"
Cohesion: 0.17
Nodes (21): Dev Versions Single Update Point, DEV_VERSIONS_FILE, install_available_packages(), install_full_vscode_dev_stack(), install_sdkman_kotlin(), install_vscode_extensions(), install_vscode_package(), package_available() (+13 more)

### Community 1 - "Graphify Workflow"
Cohesion: 0.19
Nodes (13): PreToolUse graphify hook-check, Graphify Workflow, Fast Path Existing Graph, Graphify Pipeline, Semantic Extraction Subagents, Add URL and Watch Folder, Extra Exports, Extraction Subagent Schema (+5 more)

### Community 2 - "Dotfiles Stow Docs"
Cohesion: 0.10
Nodes (17): Agent Notes, Build, Test, and Development Commands, Coding Style & Naming Conventions, Commit & Pull Request Guidelines, graphify, Helper Scripts, Project Structure & Module Organization, Repository Guidelines (+9 more)

### Community 3 - "Waybar CPU Helpers"
Cohesion: 0.25
Nodes (8): append_history, get_usage, main, render_graph, waybar-cpu-graph script, trim_history, waybar-cpu-simple script, waybar-cpu-test script

### Community 4 - "Node Installer"
Cohesion: 0.53
Nodes (5): install-node.sh script, ensure_path_line(), package_available(), record_node_warning(), resolve_first_available_package()

### Community 5 - "Dev Versions Config"
Cohesion: 0.09
Nodes (22): 0. Host prep (one-time, as admin/root), 10.1 fzf-powered tmux navigation, 10.2 tmux session persistence, 10. Terminal: Ghostty + tmux, 11. Typical “new user / new client persona” flow, 12. Troubleshooting, 1. Install minimal tools to fetch dotfiles, 2. Clone dotfiles (+14 more)

### Community 6 - "Tmux Terminal Helpers"
Cohesion: 0.40
Nodes (6): dev-terminal script, tmux-fzf-pane-switch script, tmux-fzf-session-switch script, tmux-fzf-window-switch script, tmux-sessionizer script, wifi-menu script

### Community 7 - "Lid Handler Scripts"
Cohesion: 0.40
Nodes (3): hypr-handle-lid.sh script, niri-handle-lid.sh script, sway-handle-lid.sh script

### Community 8 - "Theme Toggle"
Cohesion: 1.00
Nodes (3): theme-toggle script, set_scheme, usage

### Community 15 - "Community 15"
Cohesion: 0.14
Nodes (14): Part A - Structural extraction for code files, Part B - Semantic extraction (parallel subagents), Part C - Merge AST + semantic into final extraction, Step 0 - GitHub repos and multi-path merge (only if a URL or several paths), Step 1 - Ensure graphify is installed, Step 2.5 - Video and audio (only if video files detected), Step 2 - Detect files, Step 3 - Extract entities and relationships (+6 more)

### Community 16 - "Community 16"
Cohesion: 0.18
Nodes (10): 1. Create a dedicated test user, 2. Install minimal prerequisites, 3. Clone the repo, 4. Run bootstrap, 5. Stow the configs, 6. Log out and choose Niri in GDM, 7. In-session checks, 8. Manual checks inside Niri (+2 more)

### Community 17 - "Community 17"
Cohesion: 0.20
Nodes (9): For /graphify add and --watch, For /graphify query, For the commit hook and native CLAUDE.md integration, For --update and --cluster-only, /graphify, Honesty Rules, Interpreter guard for subcommands, Usage (+1 more)

### Community 18 - "Community 18"
Cohesion: 0.22
Nodes (8): 0. Create the user (run as root / another admin), 1. Install minimal tools (as the new user), 2. Clone dotfiles, 3. Run bootstrap script, 4. Stow dotfiles, 5. Log out and choose a session in GDM, 6. Quick sanity checks (optional), Fedora + Sway/Hyprland/Niri dotfiles – Quickstart for a NEW user

### Community 19 - "Community 19"
Cohesion: 0.22
Nodes (8): Commands And Help, Configured Bindings, Copy Mode And Buffers, Panes, Persistence Notes, Sessions, tmux Shortcut Cheat Sheet, Windows

### Community 20 - "Community 20"
Cohesion: 0.25
Nodes (7): Dotfiles Commands, Launchers And Session, Monitors And Workspaces, Niri Shortcut Cheat Sheet, Pointer And Touchpad Navigation, System Controls, Windows And Columns

### Community 21 - "Community 21"
Cohesion: 0.25
Nodes (7): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 22 - "Community 22"
Cohesion: 0.29
Nodes (7): 8. Sway keybindings, Core, Focus / move windows, Locking, Media / brightness, Network & Bluetooth helpers, Workspaces

### Community 23 - "Community 23"
Cohesion: 0.40
Nodes (4): Graphify Cost Estimator, Interpreting Results, Options, Workflow

### Community 24 - "Community 24"
Cohesion: 0.50
Nodes (3): Constraints / style, Context, Your tasks

### Community 25 - "Community 25"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 26 - "Community 26"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 27 - "Community 27"
Cohesion: 0.50
Nodes (3): For /graphify explain, For /graphify path, graphify reference: query, path, explain

### Community 28 - "Community 28"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

## Knowledge Gaps
- **118 isolated node(s):** `PreToolUse`, `dev-versions.sh script`, `install-codex-binary.sh script`, `stow-clean-restow.sh script`, `Usage` (+113 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Repository Guidelines` connect `Dotfiles Stow Docs` to `Bootstrap Dev Stack`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Why does `Fedora + Sway/Hyprland/Niri Dev Dotfiles` connect `Dev Versions Config` to `Community 22`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `Node Install` connect `Bootstrap Dev Stack` to `Node Installer`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **What connects `PreToolUse`, `dev-versions.sh script`, `install-codex-binary.sh script` to the rest of the system?**
  _119 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Dotfiles Stow Docs` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Dev Versions Config` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `Community 15` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._