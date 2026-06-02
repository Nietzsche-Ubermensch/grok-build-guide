# Cost Optimization & Enterprise Tips

Running Grok at scale — across a team or in CI — requires a little planning to keep token usage and costs under control. This guide covers practical techniques for both individual power users and organizations.

---

## Understanding What Drives Token Usage

Every Grok request consumes tokens for:

| Source | Typical Contribution |
|---|---|
| System prompt + injected context | Medium |
| MCP server tool lists | Low–Medium per server |
| File contents attached to the session | High (grows with file size) |
| Conversation history | High (grows with turn count) |
| Model response | Varies |

The biggest lever is **reducing unnecessary context**. Everything else is secondary.

---

## Tip 1: Only Connect the MCP Servers You Need

Each connected MCP server injects its full tool list into every request. Eight servers with 20 tools each add ~160 tool descriptions to every prompt.

- Use project-specific `.grok/config.toml` files to enable only the servers a project needs.
- Disable servers you are not actively using (`grok mcp disable <name>`).
- Run `/mcps` to audit what is connected before starting a long task.

---

## Tip 2: Keep Conversations Short and Focused

Grok carries the full conversation history in each request. A 50-turn conversation is significantly more expensive than five focused 10-turn sessions.

Best practice:

- Start a new Grok session for each distinct task.
- Avoid exploratory back-and-forth in the same session as a long agentic task.
- Use `grok --new` or equivalent to clear history when switching topics.

---

## Tip 3: Use `.grokignore` to Exclude Large Files

Grok respects `.grokignore` (same syntax as `.gitignore`) to prevent large or irrelevant files from being indexed and attached to requests:

```
# .grokignore
node_modules/
dist/
*.min.js
*.lock
*.png
*.jpg
*.pdf
coverage/
.DS_Store
```

Start with your `.gitignore` as a baseline and add binary/generated files on top.

---

## Tip 4: Pin Model Versions in CI

When running Grok in automated pipelines, pin to a specific model version to avoid unexpected cost increases from model upgrades:

```toml
# .grok/config.toml
[model]
name = "grok-3"
```

Review the model change log before upgrading in production.

---

## Tip 5: Use Async Patterns for Batch Jobs

For tasks that process many files or make many API calls, use async Imagine API patterns (see [imagine-api/workflows.md](../imagine-api/workflows.md)) instead of synchronous loops. Async jobs are queued efficiently and do not hold open a session connection.

---

## Tip 6: Cache Repeated Context

If your workflow repeatedly attaches the same large file (e.g., a design spec or API schema), put it in a Grok skill or reference document instead of pasting it each time. Skills are injected once per session, not once per turn.

---

## Enterprise Configuration

### Centralized Config Management

For teams, maintain a shared base config in your repository and let developers layer personal settings on top:

```toml
# .grok/config.toml (committed to repo — no secrets)
[mcpServers.github]
command = "npx"
args = ["@modelcontextprotocol/server-github"]
# GITHUB_PERSONAL_ACCESS_TOKEN supplied per-developer via shell profile

[mcpServers.db-staging]
command = "npx"
args = ["@modelcontextprotocol/server-postgres", "postgresql://staging-host/mydb"]
# DB credentials supplied via environment variable
```

### Audit Logging

Enable request logging for compliance and cost tracking:

```toml
[logging]
level = "info"
file = "~/.grok/logs/grok.log"
```

Review logs regularly to identify unexpectedly large requests.

### Token Budget Alerts

Set a soft budget in your Grok enterprise dashboard. Configure alerts at 70% and 90% of your monthly budget so you can investigate before hitting limits.

---

## Cost Comparison by Workflow

| Workflow | Relative Cost | Tips |
|---|---|---|
| Single-file questions | Low | Keep the session short |
| Repo-wide analysis | Medium | Use `.grokignore`; start fresh sessions |
| Long agentic tasks (10+ steps) | High | Break into smaller tasks; disable unused MCPs |
| Batch Imagine API jobs | Variable | Use async patterns; batch similar requests |
| CI/CD automation | Medium | Pin model; cache context in skills |

---

## Next Steps

- [Grok Imagine API Workflows](../imagine-api/workflows.md) — async patterns that reduce cost for bulk image/video jobs
- [mcp-list Best Practices](mcp-list-best-practices.md) — manage server overhead
