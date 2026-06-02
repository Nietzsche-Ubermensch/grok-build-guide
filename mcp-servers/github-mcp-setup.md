# GitHub MCP Server Setup

The GitHub MCP server gives Grok full access to the GitHub API — creating pull requests, opening issues, managing branches, and much more. This guide walks you through installation, authentication, and verification.

---

## Prerequisites

- Grok Build installed and working
- A GitHub account
- `npx` / Node.js ≥ 18 available (`node --version`)

---

## Step 1: Create a Personal Access Token (PAT)

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**.
2. Click **Generate new token (classic)**.
3. Give it a descriptive name, e.g. `grok-mcp`.
4. Set an expiry that matches your security policy (90 days is a reasonable default).
5. Select the scopes you need:

   | Scope | Why You Need It |
   |---|---|
   | `repo` | Read/write access to repositories (required) |
   | `read:org` | Read organization membership |
   | `workflow` | Manage GitHub Actions workflows |
   | `read:user` | Read your user profile |

6. Click **Generate token** and **copy it immediately** — GitHub will not show it again.

> **Security tip:** Store your PAT in a password manager or secrets vault. Never commit it to source control.

---

## Step 2: Add the GitHub MCP Server

Run this command inside any Grok session (or from your terminal with Grok installed):

```bash
grok mcp add github --command npx --args @modelcontextprotocol/server-github
```

Grok will download the server package on first run via `npx`.

---

## Step 3: Authenticate

Grok will prompt you for your GitHub token. Paste the PAT you created in Step 1.

Alternatively, configure it manually in your Grok config file:

```toml
# ~/.grok/config.toml  (global)
# or .grok/config.toml (project-specific — do NOT commit this file)

[mcpServers.github]
command = "npx"
args = ["@modelcontextprotocol/server-github"]
env = { GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_your_token_here" }
```

> **Project-specific config:** Add `.grok/config.toml` to your `.gitignore` to avoid accidentally committing your PAT.

---

## Step 4: Verify Installation

Inside a Grok session, type:

```
/mcps
```

You should see `github` listed among your connected MCP servers, similar to:

```
Connected MCP Servers:
  ✅ github      (npx @modelcontextprotocol/server-github)
  ✅ filesystem  (npx @modelcontextprotocol/server-filesystem)
```

Test it end-to-end with a real command:

```
List the last 5 open pull requests in my-org/my-repo.
```

---

## Comparison of Connection Methods

| Method | Difficulty | What Grok Can Do | Best For |
|---|---|---|---|
| Local Git folder | Easy | Read files, run git commands, understand project | Most day-to-day coding |
| GitHub MCP Server | Medium | Create PRs, issues, branches, full GitHub API access | Power users & automation |
| Web UI (grok.com) | Easy | Analyze public repos (limited) | Quick questions only |

---

## Troubleshooting

### `npx` command not found

Install Node.js (≥ 18) from [nodejs.org](https://nodejs.org) or via your package manager:

```bash
# macOS (Homebrew)
brew install node

# Ubuntu / Debian
sudo apt install nodejs npm
```

### Token permissions error

If Grok returns a `403 Forbidden` or `Resource not accessible by integration` error, your PAT is missing a required scope. Regenerate the token and add the missing scope from the table in Step 1.

### Server not appearing in `/mcps`

- Confirm the config file is valid TOML (no syntax errors).
- Restart the Grok session after editing the config file.
- Run `npx @modelcontextprotocol/server-github` manually to check for install errors.

---

## Next Steps

- [mcp-list Best Practices](../guides/mcp-list-best-practices.md) — how to manage multiple servers
- [examples/github-mcp-config.toml](../examples/github-mcp-config.toml) — copy-paste config snippet
