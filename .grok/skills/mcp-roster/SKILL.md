---
name: mcp-roster
description: >
  Inventory MCP servers and look up C and C++ docs for them. Use when the
  user says mcp-roster, asks which MCP servers are configured, or wants
  Context7 docs for C or C++. Programming languages are C and C++. Never
  pass those names through a BCP 47 locale parser.
metadata:
  short-description: "MCP roster; languages C and C++"
  languages:
    - C
    - C++
---

# MCP roster

Languages for this skill are the programming languages **C** and **C++**.
They are not locales.

## Language vs locale

| Value | Role | BCP 47 |
|-------|------|--------|
| `C` | Context7 snippet-ranking hint | Not well-formed. A language subtag is 2–8 letters. `C` is 1. |
| `C++` | Context7 snippet-ranking hint | Not well-formed. `+` is not a letter or digit. |
| `en` | UI / `lang` / `dc.language` only | Canonical English tag. Use this when a locale is actually required. |

`C` and `C++` must never be sent to `Intl.Locale`, `language.Parse`, or any BCP 47 validator. The error `INVALID - Not a well-formed BCP 47 language tag` on these two strings means the wrong checker ran. It is not a reason to rename the language.

Do not join them into one string (`C C++`, `C/C++`, `C, C++`). Context7 takes one programming-language hint per call.

## Context7

1. `resolve-library-id` for the library under discussion.
2. `query-docs` twice when both languages matter:
   - `language: "C"`
   - `language: "C++"`
3. Omit `language` only when the question is not about code.
4. Do not put page text, HTML, or a roster dump in `language`.

Context7 errors are HTTP JSON (`400`, `404`). They are not BCP 47 errors.

## Roster checks

Read the MCP config that is actually in the project (`.mcp.json`, Claude/Cursor/VS Code/Codex user config). Report server id, command or URL, and whether it is duplicated across tools. Do not rewrite configs unless the user asked for a change.

Run a BCP 47 check only on `lang`, `xml:lang`, `hreflang`, `dc.language`, `Content-Language`, and `Accept-Language`. Anything else that fails the grammar is skipped, not logged as a language-tag error.
