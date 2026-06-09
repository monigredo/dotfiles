# Graph Report - .  (2026-06-09)

## Corpus Check
- Corpus is ~19,467 words - fits in a single context window. You may not need a graph.

## Summary
- 89 nodes · 113 edges · 15 communities (9 shown, 6 thin omitted)
- Extraction: 74% EXTRACTED · 26% INFERRED · 0% AMBIGUOUS · INFERRED: 29 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

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

## God Nodes (most connected - your core abstractions)
1. `Graphify Pipeline` - 8 edges
2. `install_full_vscode_dev_stack()` - 7 edges
3. `record_fallback_warning()` - 6 edges
4. `Bootstrap Script` - 6 edges
5. `bootstrap-fedora-dev.sh script` - 5 edges
6. `Repository Guidelines` - 5 edges
7. `Preferred Development Tool Targets` - 5 edges
8. `Node Install` - 5 edges
9. `package_available()` - 4 edges
10. `resolve_first_available_package()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Node Install` --implements--> `VS Code Dev Stack`  [INFERRED]
  scripts/install-node.sh → README.md
- `install_vscode_package()` --implements--> `VS Code Dev Stack`  [INFERRED]
  bootstrap-fedora-dev.sh → README.md
- `Repository Guidelines` --references--> `Preferred Development Tool Targets`  [EXTRACTED]
  AGENTS.md → config/dev-versions.sh
- `Dev Versions Single Update Point` --rationale_for--> `Preferred Development Tool Targets`  [EXTRACTED]
  AGENTS.md → config/dev-versions.sh
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

## Communities (15 total, 6 thin omitted)

### Community 0 - "Bootstrap Dev Stack"
Cohesion: 0.26
Nodes (14): install_available_packages(), install_full_vscode_dev_stack(), install_sdkman_kotlin(), install_vscode_extensions(), install_vscode_package(), package_available(), record_fallback_warning(), resolve_first_available_package() (+6 more)

### Community 1 - "Graphify Workflow"
Cohesion: 0.19
Nodes (13): PreToolUse graphify hook-check, Graphify Workflow, Fast Path Existing Graph, Graphify Pipeline, Semantic Extraction Subagents, Add URL and Watch Folder, Extra Exports, Extraction Subagent Schema (+5 more)

### Community 2 - "Dotfiles Stow Docs"
Cohesion: 0.18
Nodes (9): Helper Scripts, Repository Guidelines, install-codex-binary.sh script, stow-clean-restow.sh script, Fedora Wayland Dotfiles, GNU Stow, cleanup(), Codex Binary Install (+1 more)

### Community 3 - "Waybar CPU Helpers"
Cohesion: 0.25
Nodes (8): append_history, get_usage, main, render_graph, waybar-cpu-graph script, trim_history, waybar-cpu-simple script, waybar-cpu-test script

### Community 4 - "Node Installer"
Cohesion: 0.48
Nodes (6): install-node.sh script, ensure_path_line(), Node Install, package_available(), record_node_warning(), resolve_first_available_package()

### Community 5 - "Dev Versions Config"
Cohesion: 0.33
Nodes (6): Dev Versions Single Update Point, DEV_VERSIONS_FILE, Preferred Development Tool Targets, AI Bootstrap Context, Bootstrap Script, rofi-bluetooth

### Community 6 - "Tmux Terminal Helpers"
Cohesion: 0.40
Nodes (6): dev-terminal script, tmux-fzf-pane-switch script, tmux-fzf-session-switch script, tmux-fzf-window-switch script, tmux-sessionizer script, wifi-menu script

### Community 7 - "Lid Handler Scripts"
Cohesion: 0.40
Nodes (3): hypr-handle-lid.sh script, niri-handle-lid.sh script, sway-handle-lid.sh script

### Community 8 - "Theme Toggle"
Cohesion: 1.00
Nodes (3): theme-toggle script, set_scheme, usage

## Knowledge Gaps
- **14 isolated node(s):** `PreToolUse`, `dev-versions.sh script`, `install-codex-binary.sh script`, `stow-clean-restow.sh script`, `Helper Scripts` (+9 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Node Install` connect `Node Installer` to `Bootstrap Dev Stack`, `Dev Versions Config`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Why does `Repository Guidelines` connect `Dotfiles Stow Docs` to `Bootstrap Dev Stack`, `Dev Versions Config`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Why does `Bootstrap Script` connect `Dev Versions Config` to `Bootstrap Dev Stack`, `Dotfiles Stow Docs`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Graphify Pipeline` (e.g. with `PreToolUse graphify hook-check` and `Extra Exports`) actually correct?**
  _`Graphify Pipeline` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PreToolUse`, `dev-versions.sh script`, `install-codex-binary.sh script` to the rest of the system?**
  _15 weakly-connected nodes found - possible documentation gaps or missing edges._