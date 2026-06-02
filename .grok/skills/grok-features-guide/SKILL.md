---
name: grok-features-guide
description: >
  Explain Grok Build features: skills discovery, plugins, hooks, marketplaces,
  subagents, and Claude/Cursor/AGENTS.md compatibility. Use when the user asks how
  Grok extensions work, where skills or plugins load from, hook env vars, marketplace
  config, or runs /grok-features-guide.
metadata:
  short-description: "Grok skills, plugins, hooks, marketplaces"
---

# Grok Features Guide

Reference for developers and system administrators. Paths are relative to the user home directory or current working directory unless noted. After changing `~/.grok/config.toml`, restart Grok or reload extensions in the TUI.

## Skills

Skills are reusable folders that contain markdown instructions, script files, and supporting resources for agents.

**Discovery locations** (searched in this order):

- `./.grok/skills/` (walked up to the repository root)
- `~/.grok/skills/`
- Enabled plugin’s `skills/` directory
- Additional paths listed under `[skills] paths` in `~/.grok/config.toml`

**Usage:** User-invocable skills appear as slash commands (e.g. `/<skill-name>`).

When answering “where is my skill?”:

1. Check project `.grok/skills/<name>/` (highest priority for that repo).
2. Check `~/.grok/skills/<name>/`.
3. Check enabled plugins via `/plugins` or `grok plugin list`.
4. Read `[skills] paths` and `ignore` in `~/.grok/config.toml`.

For authoring format, read `~/.grok/docs/user-guide/08-skills.md`.

## Plugins

Plugins extend Grok with additional skills, agents, hooks, MCP servers, and LSP servers.

**Loading locations:**

- `./.grok/plugins/`
- `~/.grok/plugins/`
- Marketplace installations under `~/.grok/plugins/marketplaces/`
- Additional paths under `[plugins] paths` in `~/.grok/config.toml`
- Command-line flag: `--plugin-dir <PATH>`

**Management:** Use the extensions modal in the TUI (`/plugins`, `/hooks`, `/skills`, `/mcps`).

Canonical manifest on grok 0.2.16+ is **`plugin.json`** at the plugin root; optional `plugin.toml` may exist for human authoring only.

## Hooks

Hooks execute scripts during tool and session lifecycle events (pre- or post-tool calls, etc.).

**Discovery locations:**

- `~/.grok/hooks/` (extra roots via `~/.grok/hooks-paths`)
- Project-specific `.grok/hooks/` (requires `/hooks-trust`)
- Enabled plugins

**Environment variables** passed to hooks:

- `GROK_HOOK_EVENT`, `GROK_HOOK_NAME`, `GROK_SESSION_ID`, `GROK_WORKSPACE_ROOT`
- For plugin hooks: `GROK_PLUGIN_ROOT`, `GROK_PLUGIN_DATA`

**Priority:** Runner and plugin values override any `env` variables declared in the hook definition. See `~/.grok/docs/user-guide/10-hooks.md`.

## Marketplaces

The TUI Marketplace tab allows browsing and installing plugins from configured sources.

**Source configuration:**

- Defined in `[[marketplace.sources]]` sections of `~/.grok/config.toml`
- Also stored in `~/.grok/plugins/known_marketplaces.json`

## Subagents

Subagents spawn independent child sessions that handle tasks concurrently, enabling parallel processing within a single Grok session.

See `~/.grok/docs/user-guide/16-subagents.md`.

## Compatibility

**Claude Code:** Grok reads Claude Code marketplaces, plugins, skills, MCPs, agents, hooks, and `CLAUDE.md` without extra configuration.

**AGENTS.md:** User-level skills and commands from `~/.agents/skills/` and `~/.agents/commands/`.

Vendor toggles: `[compat.claude]` and `[compat.cursor]` in `~/.grok/config.toml`.

## How to use this skill

1. Identify which section applies.
2. Answer with discovery order and config keys above.
3. Point to the matching file under `~/.grok/docs/user-guide/` for detail.
4. If needed, read `~/.grok/config.toml` — do not guess paths.
