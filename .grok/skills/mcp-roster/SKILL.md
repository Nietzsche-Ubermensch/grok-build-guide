---
name: mcp-roster
description: >
  Inventory MCP servers and look up C and C++ docs for them. Use when the
  user says mcp-roster, asks which MCP servers are configured, or wants
  Context7 docs for C or C++. Programming languages are C and C++. Locale
  codes go through the SimpleLocalize converter, never those language names.
metadata:
  short-description: "MCP roster; C and C++ code, BCP 47 locales"
  languages:
    - C
    - C++
  locale-converter: https://simplelocalize.io/tools/locale-code-converter/
---

# MCP roster

Two different "language" values. Do not mix them.

| Kind | Values | Where it goes |
|------|--------|----------------|
| Programming language | `C`, `C++` | Context7 `language` hint, one call per value |
| Locale | BCP 47 tag such as `en`, `en-US`, `zh-Hans-CN` | `lang`, `Intl`, Android, iOS, .NET, POSIX |

## Programming languages

`C` and `C++` are not locales. Do not pass them to a BCP 47 parser or to the [locale code converter](https://simplelocalize.io/tools/locale-code-converter/).

| Hint | Why a BCP 47 check fails |
|------|--------------------------|
| `C` | One letter. A language subtag is 2–8 letters. |
| `C++` | `+` is not a letter or digit. |

That failure is the wrong checker. It is not a reason to rename the language.

Context7 takes one hint per call. Call `query-docs` with `language: "C"` and, when C++ matters, again with `language: "C++"`. Do not join them (`C C++`, `C/C++`). Do not put page text, HTML, or a roster dump in `language`.

The POSIX locale whose name is `C` (ASCII, no language) is also not this programming language. This skill does not emit it.

## Locales

Convert locale identifiers with the SimpleLocalize converter. Store the canonical form as BCP 47 (hyphens). Derive the other four spellings at the edge that needs them.

| Format | Example | Used by |
|--------|---------|---------|
| BCP 47 / IETF | `zh-Hans-CN` | HTML `lang`, JavaScript `Intl`, Flutter |
| POSIX / Java | `zh_Hans_CN` | Linux, `java.util.Locale`, gettext. Optional charset: `pt_BR.UTF-8` |
| Android | `values-b+zh+Hans+CN` | `res/` folder. Simple language-region stays `values-pt-rBR` |
| iOS / macOS | `zh-Hans-CN.lproj` | Xcode |
| .NET culture | `zh-Hans-CN` | `CultureInfo` |

Normalize before any well-formedness check:

1. Strip a trailing `.lproj`.
2. Strip a POSIX charset suffix (`.UTF-8`).
3. `values-b+zh+Hans+CN` → join the `+` parts after `b+` with hyphens → `zh-Hans-CN`.
4. `values-pt-rBR` → `pt-BR` (drop `values-`, drop the `r` on the region).
5. Turn remaining underscores into hyphens (`en_US` → `en-US`, `pl_PL` → `pl-PL`). Underscores are POSIX spelling, not an invalid tag.
6. If the result is a 3-letter ISO 639-2/3 code and a 2-letter code exists, use the 2-letter code. `eng` → `en`. ISO 639-2 for English stays `eng` only in the ISO column, not in `lang`.

| Input | BCP 47 | POSIX | Android | iOS | .NET | ISO 639-1 | ISO 639-2 |
|-------|--------|-------|---------|-----|------|-----------|-----------|
| `eng` | `en` | `en` | `values-en` | `en.lproj` | `en` | `en` | `eng` |
| `en-US` | `en-US` | `en_US` | `values-en-rUS` | `en-US.lproj` | `en-US` | `en` | `eng` |
| `en_US` | `en-US` | `en_US` | `values-en-rUS` | `en-US.lproj` | `en-US` | `en` | `eng` |
| `pl_PL` | `pl-PL` | `pl_PL` | `values-pl-rPL` | `pl-PL.lproj` | `pl-PL` | `pl` | `pol` |
| `zh-Hans-CN` | `zh-Hans-CN` | `zh_Hans_CN` | `values-b+zh+Hans+CN` | `zh-Hans-CN.lproj` | `zh-Hans-CN` | `zh` | `zho` |

Do not add a region unless a separate translation exists. `fr` is the fallback, not a missing `fr-CA`. For Chinese, keep the script (`zh-Hans`, `zh-Hant`).

Run a BCP 47 check only after this normalization, and only on `lang`, `xml:lang`, `hreflang`, `dc.language`, `Content-Language`, and `Accept-Language`. Anything that is still not a locale shape is skipped, not logged as `INVALID - Not a well-formed BCP 47 language tag`.

## Roster checks

Read the MCP config that is actually in the project (`.mcp.json`, Claude/Cursor/VS Code/Codex user config). Report server id, command or URL, and whether it is duplicated across tools. Do not rewrite configs unless the user asked for a change.
