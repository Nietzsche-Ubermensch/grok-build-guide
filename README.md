# Grok Build Guide

> Practical, opinionated documentation for **Grok Build** users — from first-time setup to advanced automation.

---

## Overview

This repository collects guides, configuration examples, and best practices for:

- Connecting Grok to your local codebase and Git workflow
- Setting up MCP servers (GitHub, filesystem, and more)
- Automating image and video generation with the Grok Imagine API
- Reducing costs and scaling usage for teams and enterprises

Whether you are just getting started or looking to squeeze more out of Grok's agentic capabilities, you'll find something useful here.

---

## Quick Navigation

| Section | What's Inside |
|---|---|
| [guides/](guides/) | End-to-end how-to guides for common workflows |
| [mcp-servers/](mcp-servers/) | MCP server setup, authentication, and troubleshooting |
| [imagine-api/](imagine-api/) | Grok Imagine API workflows and async patterns |
| [examples/](examples/) | Ready-to-use config snippets and scripts |

---

## Guides

| Guide | Description |
|---|---|
| [Connecting Local Git Repositories](guides/connecting-local-git.md) | Point Grok at any local repo so it can read your code and run Git commands |
| [GitHub MCP Server Setup](mcp-servers/github-mcp-setup.md) | Install and authenticate the GitHub MCP server for full GitHub API access |
| [mcp-list Best Practices](guides/mcp-list-best-practices.md) | How to use the `/mcps` skill effectively and manage multiple servers |
| [Cost Optimization & Enterprise Tips](guides/cost-optimization.md) | Reduce token usage, cache responses, and scale for teams |

## Imagine API

| Guide | Description |
|---|---|
| [Workflows Overview](imagine-api/workflows.md) | Multi-image editing, video generation, and async request patterns |

## Examples

| File | Description |
|---|---|
| [examples/github-mcp-config.toml](examples/github-mcp-config.toml) | Minimal GitHub MCP server config |
| [examples/multi-image-edit.sh](examples/multi-image-edit.sh) | Shell script for batch Imagine API edits |
| [examples/async-poll.py](examples/async-poll.py) | Python snippet for polling async Imagine API jobs |

---

## Contributing

Pull requests are welcome. Please keep prose concise, use fenced code blocks with language tags, and test any shell/Python snippets before submitting.

## License

[MIT](LICENSE)
