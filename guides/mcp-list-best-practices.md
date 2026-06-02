# mcp-list Best Practices

The `/mcps` command (also callable as `/mcp-list`) is Grok's built-in tool for inspecting and managing your connected MCP servers. This guide covers how to use it efficiently and avoid common pitfalls when running multiple servers.

---

## What `/mcps` Shows You

Running `/mcps` inside any Grok session prints a status table:

```
Connected MCP Servers:
  ✅ github      (npx @modelcontextprotocol/server-github)   tools: 28
  ✅ filesystem  (npx @modelcontextprotocol/server-filesystem) tools: 6
  ❌ postgres    (npx @modelcontextprotocol/server-postgres)  ERROR: connection refused
```

Each row shows:

| Column | Meaning |
|---|---|
| Status icon | `✅` connected, `❌` error, `⏳` connecting |
| Server name | The key from your `[mcpServers.*]` config block |
| Command | How the server process is launched |
| `tools:` count | Number of tools the server exposes to Grok |

---

## Tip 1: Check Server Status Before Long Tasks

Before starting a long agentic workflow, always run `/mcps` to confirm every server you need is connected. A missing server mid-task causes incomplete results that are hard to recover from.

```
/mcps
# Confirm all required servers are ✅ before proceeding
Create a PR that fixes the failing tests in my-org/my-repo.
```

---

## Tip 2: Name Servers Descriptively

Config key names appear in `/mcps` output and in Grok's tool-selection reasoning. Short but descriptive names help Grok route requests to the right server.

```toml
# Good
[mcpServers.github-work]
[mcpServers.github-personal]
[mcpServers.db-staging]

# Avoid — ambiguous
[mcpServers.server1]
[mcpServers.mcp]
```

---

## Tip 3: Use Project-Specific Configs to Limit Scope

Global configs (`~/.grok/config.toml`) load every server for every session. Project-specific configs (`.grok/config.toml` in your repo root) load only what that project needs.

```toml
# .grok/config.toml  (project-specific, committed without secrets)
[mcpServers.github]
command = "npx"
args = ["@modelcontextprotocol/server-github"]
# Token supplied via environment variable — NOT hardcoded here
```

Set the token in your shell profile or CI environment:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_..."
```

This way the config file is safe to commit and each developer supplies their own token.

---

## Tip 4: Disable Servers You Are Not Using

Every connected server adds a small overhead to each Grok request (tool-list injection into the context). If a server is not needed for a session, disable it:

```bash
grok mcp disable postgres
```

Or remove it temporarily from your config and run `/mcps` to confirm it's gone.

---

## Tip 5: Use `/mcps refresh` After Config Changes

After editing your config file, you do not need to restart Grok. Use:

```
/mcps refresh
```

This reloads all server configurations and reconnects any that were modified.

---

## Tip 6: Check Tool Counts to Spot Partial Failures

A server may connect but expose fewer tools than expected if it starts in a degraded state. Compare the `tools:` count against the server's documentation:

| Server | Expected Tool Count |
|---|---|
| `@modelcontextprotocol/server-github` | ~28 |
| `@modelcontextprotocol/server-filesystem` | 6 |
| `@modelcontextprotocol/server-postgres` | 4–6 |

If the count is lower, check the server process logs or re-authenticate.

---

## Tip 7: Prefer Env Vars Over Inline Tokens

Never put PATs or passwords directly in the `args` array — they appear in process lists and are hard to rotate. Use the `env` block and reference environment variables:

```toml
[mcpServers.github]
command = "npx"
args = ["@modelcontextprotocol/server-github"]
env = { GITHUB_PERSONAL_ACCESS_TOKEN = "${GITHUB_PAT}" }
```

---

## Common Errors and Fixes

| Error | Likely Cause | Fix |
|---|---|---|
| `ERROR: connection refused` | Server process not running or wrong port | Restart the server; check command and args |
| `ERROR: spawn ENOENT` | Command (`npx`, `python`, etc.) not on PATH | Install the runtime or use an absolute path |
| `tools: 0` | Server connected but no tools registered | Check server version; update with `npm update -g` |
| Server not listed | Config block missing or TOML syntax error | Validate TOML; run `/mcps refresh` |

---

## Installing the mcp-list Skill

The **mcp-list skill** turns Grok into an interactive MCP installer. Instead of searching for package names, just ask Grok which server you need and it will give you the exact `grok mcp add` command.

### Step 1: Create the Skill Folder

```bash
mkdir -p ~/.grok/skills/mcp-list
```

### Step 2: Create the SKILL.md File

Copy the canonical skill file from this repository:

```bash
cp examples/skills/mcp-list/SKILL.md ~/.grok/skills/mcp-list/SKILL.md
```

Or create it manually — the full file content is at
[examples/skills/mcp-list/SKILL.md](../examples/skills/mcp-list/SKILL.md).

### Step 3: Reload Skills

Inside Grok, run:

```
/mcps
```

Grok re-reads the skills directory on each session start. If Grok is already running, start a new session to pick up the new skill.

### Using the Skill

Once installed, you can ask Grok things like:

```
Which MCP should I use for web scraping?
Give me the install command for the PostgreSQL MCP server.
What MCPs are available for Slack?
```

Grok will consult the skill's server table and return the exact `grok mcp add` command.

> **Tip:** The skill works best on WSL (Windows Subsystem for Linux) where `npx` is reliably available. On native Windows, ensure Node.js is on your PATH.

---

## Next Steps

- [GitHub MCP Server Setup](../mcp-servers/github-mcp-setup.md) — add and authenticate the GitHub server
- [Cost Optimization & Enterprise Tips](cost-optimization.md) — reduce overhead from many servers
