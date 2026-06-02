# Connecting Grok to Local Git Repositories

Giving Grok access to your local codebase is the fastest way to get context-aware help — no uploads required. This guide covers three ways to do it, from the simplest to the most powerful.

---

## Prerequisites

- Grok Build installed (`grok --version` should print a version number)
- A local Git repository you want to work with

---

## Method 1: Open a Folder in Grok (Recommended for Beginners)

The quickest way is to launch Grok from inside your project directory.

```bash
cd ~/projects/my-app
grok
```

Grok automatically detects the Git repository root and indexes the working tree. You can then ask questions like:

```
What does the AuthService class do?
Show me all TODO comments in this repo.
Run git log --oneline -20 and summarize recent changes.
```

### What Grok Can See

| Capability | Available |
|---|---|
| Read source files | ✅ |
| Run `git` commands | ✅ |
| Understand project structure | ✅ |
| Create branches / PRs | ❌ (needs GitHub MCP) |

---

## Method 2: Specify a Path Explicitly

If you want to open a project that is not your current directory:

```bash
grok --path ~/projects/other-app
```

You can also open multiple folders in one session using the filesystem MCP server — see [mcp-servers/github-mcp-setup.md](../mcp-servers/github-mcp-setup.md) for the pattern.

---

## Method 3: Add the Filesystem MCP Server

For fine-grained control over which directories Grok can access, add the filesystem MCP server:

```bash
grok mcp add filesystem --command npx --args @modelcontextprotocol/server-filesystem /path/to/project
```

You can add multiple paths by repeating the `--args` flag:

```bash
grok mcp add filesystem \
  --command npx \
  --args @modelcontextprotocol/server-filesystem \
  --args /home/user/projects/frontend \
  --args /home/user/projects/backend
```

Or configure it manually in `~/.grok/config.toml`:

```toml
[mcpServers.filesystem]
command = "npx"
args = [
  "@modelcontextprotocol/server-filesystem",
  "/home/user/projects/frontend",
  "/home/user/projects/backend"
]
```

---

## Verifying the Connection

Inside a Grok session, ask:

```
What is the root of the current project?
List the top-level files and folders.
```

If Grok returns your actual project tree, the connection is working.

---

## Comparison of Methods

| Method | Difficulty | Best For |
|---|---|---|
| `grok` in project dir | Easy | Single-project, day-to-day work |
| `grok --path <dir>` | Easy | Opening a specific folder without `cd` |
| Filesystem MCP server | Medium | Multi-root workspaces, restricted access |
| GitHub MCP server | Medium | Full GitHub API (PRs, issues, branches) |

---

## Next Steps

- [GitHub MCP Server Setup](../mcp-servers/github-mcp-setup.md) — unlock PR creation and full GitHub API access
- [mcp-list Best Practices](mcp-list-best-practices.md) — manage multiple MCP servers efficiently
