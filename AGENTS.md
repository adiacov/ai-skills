# AGENTS.md

Instructions for AI agents working in this repository. This is the single source of
instructions: `CLAUDE.md` and any other agent-specific file only point here. Do not
duplicate these rules in other files.

## Purpose

This repository creates and stores reusable **agent skills**: folders with a `SKILL.md`
file that any agent supporting the open Agent Skills format can load (Claude Code,
Codex, Gemini CLI, Cursor, GitHub Copilot and others). Skills can cover any topic:
coding, writing, research, planning, personal productivity, and so on.

Two kinds of work happen here:

1. **Creating or improving skills** at the owner's request (the most common task).
2. **Maintaining the repository**: scripts, templates, documentation.

The repository is **public** and MIT licensed. Everything committed is visible to anyone.

## Repository layout

```
skills/<skill-name>/      One folder per skill (flat, no category subfolders)
  SKILL.md                Required: frontmatter + instructions
  references/             Optional: detailed docs loaded only when needed
  scripts/                Optional: helper scripts the skill runs
  assets/                 Optional: templates, images, data files used in output
  evals/cases.md          Optional: test requests for checking the skill
templates/skill/          Starting point for new skills; copy, never edit in place
scripts/validate.sh       Checks every skill against the format rules
scripts/install.sh        Installs skills into an agent's skills directory
scripts/package.sh        Builds dist/<skill>.zip for upload-based apps
CHANGELOG.md              Dated list of notable changes
README.md                 Human-facing overview, including the skills catalog
```

Keep `skills/` flat: agents and install tools expect `skills/<name>/SKILL.md`.
Express categories with `metadata.category` instead of folders.

## SKILL.md format

Every `SKILL.md` starts with YAML frontmatter, followed by Markdown instructions.

```yaml
---
name: pdf-summarizer
description: Summarizes PDF documents into key points and action items. Use when the user shares a PDF and asks for a summary, overview, or "the main points".
license: MIT
metadata:
  version: "1.0.0"
  category: writing
---
```

| Field           | Required | Rules                                                                     |
| --------------- | -------- | ------------------------------------------------------------------------- |
| `name`          | yes      | 1-64 chars, lowercase letters, digits, single hyphens; equals folder name |
| `description`   | yes      | Max 1024 chars; says what the skill does **and** when to use it           |
| `license`       | no       | Use `MIT` unless the skill includes material under another license        |
| `compatibility` | no       | Max 500 chars; only when the skill needs specific tools, OS or network    |
| `metadata`      | no       | String values only; this repo uses `version` and `category`               |
| `allowed-tools` | no       | Experimental; avoid unless a specific agent requires it                   |

Do not add other top-level keys. Agent-specific keys (for example Claude Code-only
fields) make a skill less portable; use them only when the owner asks, and mention the
agent in `compatibility`.

Categories in use: `coding`, `writing`, `research`, `productivity`, `data`, `design`,
`devops`, `general`. Add a new one only when none fit.

## Creating a new skill

1. **Understand the need.** Ask the owner what the skill should achieve, two or three
   example requests that should trigger it, and what a good result looks like. Skip
   questions the request already answers.
2. **Check for overlap.** Look through `skills/` and the catalog in `README.md`. If an
   existing skill covers most of it, propose extending that skill instead.
3. **Copy the template:** `cp -R templates/skill skills/<skill-name>`, then fill in
   every section. Delete sections that do not apply and the `evals/` folder if no
   test cases are useful.
4. **Write the description first.** It is the only part an agent reads before deciding
   to load the skill, so it decides whether the skill is ever used.
5. **Write the body** following the writing rules below.
6. **Add test cases** in `evals/cases.md`: requests that should trigger the skill, and
   similar ones that should not.
7. **Validate:** run `scripts/validate.sh` and fix all errors and warnings.
8. **Update the catalog** table in `README.md` (keep it sorted by name) and add a line
   to `CHANGELOG.md` under today's date.
9. **Report back** with the skill's name, what it does, and how to try it.

## Writing rules

**Description**
- State what the skill does, then when to use it: "Use when ...".
- Include the words people actually say ("summarize", "tl;dr", "main points").
- Write in the third person; do not start with "I" or "You".

**Body**
- Write direct, numbered instructions in the imperative ("Ask for ...", "Check ...").
- Explain *why* a rule exists when it is not obvious; agents follow rules better when
  they understand the reason.
- Include at least one concrete example of a request and the expected result.
- Keep `SKILL.md` under 500 lines. Move long reference material into `references/`
  and say in the body exactly when to read each file.
- Refer to bundled files with relative paths (`references/style-guide.md`).
- Write for any agent: do not assume a particular product, model or tool name unless
  the skill is explicitly for that product.
- Keep the language plain. Many skills are used by people without a technical
  background, and the instructions should be readable by them too.

**Scripts**
- Use scripts only for steps that must be exact or repeatable (calculations, file
  conversion, validation). Prefer Python 3 or POSIX shell with no extra dependencies.
- Every script prints a usage message with `--help` and fails with a clear error.
- No network access, credentials or destructive operations unless the skill's purpose
  requires them, and then say so in the body and in `compatibility`.

## Editing an existing skill

- Never rename a skill without the owner's approval: installed copies and habits
  depend on the name.
- Bump `metadata.version`: patch for wording fixes, minor for new behavior, major for
  changes that alter what the skill produces.
- Add a `CHANGELOG.md` entry and update the README catalog if the description changed.
- Re-run `scripts/validate.sh`.

## Public repository rules

- Never commit secrets, API keys, tokens, passwords or private URLs.
- Never include personal data (names, emails, addresses, client or employer details)
  in skills, examples or test cases. Use neutral placeholders such as `Example Corp`.
- Only include third-party content that may be redistributed, and credit the source.

## Commits

- Commit only when the owner asks.
- Message format: `<skill-name>: <summary>` for skill changes, `repo: <summary>` for
  everything else. Example: `pdf-summarizer: handle scanned documents`.
- Do not commit generated files (`dist/`, `*.zip`, `*-workspace/`); `.gitignore`
  already excludes them.
- The pre-commit hook runs `scripts/validate.sh`. Enable it once per clone with
  `git config core.hooksPath .githooks`. Do not bypass it with `--no-verify`.
