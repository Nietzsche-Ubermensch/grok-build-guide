# grok-build-guide

Practical guides and **project skills** for [Grok Build](https://x.ai) — skills, plugins, hooks, marketplaces, MCP, and GitHub integration.

## Quick start

Clone this repo and open it in Grok (or any cwd under the tree). Project skills load from `.grok/skills/` automatically.

```bash
git clone https://github.com/Nietzsche-Ubermensch/grok-build-guide.git
cd grok-build-guide
grok
```

## Bundled project skills

| Skill | Slash | Purpose |
|-------|-------|---------|
| [grok-features-guide](.grok/skills/grok-features-guide/) | `/grok-features-guide` | Where skills, plugins, hooks, and marketplaces load from |
| [strict-code-implementer](.grok/skills/strict-code-implementer/) | `/strict-code-implementer` | Full production code only — no stubs, mocks, or placeholders |

## Related repos

| Repo | Role |
|------|------|
| [grok-gateway](https://github.com/Nietzsche-Ubermensch/grok-gateway) | Gateway service; long-form `docs/GROK_BUILD_GUIDE.md` (illustrative + gateway-specific) |
| [grok-devkit](https://github.com/xai-org/grok-devkit) | Installable plugin (`plugin.json`, hooks, MCP) — normative layout in gateway design doc |

**Normative CLI 0.2.16 layout:** `plugin.json`, `hooks/hooks.json`, root `.mcp.json` — see `grok-gateway` → `docs/design/grok-devkit.md`. Legacy `plugin.toml`-only trees in older guide sections are illustrative.

## Docs (in this repo)

- `docs/` — focused guides (add over time)
- Upstream user guides ship with the CLI under `~/.grok/docs/user-guide/`

## License

Apache-2.0 — see [LICENSE](LICENSE).
