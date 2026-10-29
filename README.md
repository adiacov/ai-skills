# AI Skills

A personal collection of reusable **skills** for AI assistants and agents.

## What is a skill?

A skill is a small folder of instructions that teaches an AI assistant how to do a
specific task well, such as summarizing a document in a set format, reviewing code,
or planning a trip. The main file in each folder is `SKILL.md`: a short description
of when to use the skill, followed by step-by-step instructions.

The assistant reads only the short description until a request matches it. Then it
loads the full instructions and follows them. This means you can install many skills
without slowing the assistant down, and you don't have to explain the same task again
every time.

Skills use an open format, so the same skill works in many tools, including Claude,
Codex, Gemini CLI, Cursor and GitHub Copilot.

## Why this repository exists

- **One place for all skills.** Every skill is written once, stored here, and reused
  in any assistant or project.
- **A workshop for new skills.** The repository includes instructions
  ([AGENTS.md](AGENTS.md)) that teach an AI agent how to create good skills, so new
  ones can be made by simply asking for them.

## Skills catalog

| Skill | Category | What it does |
| ----- | -------- | ------------ |
| _None yet_ | | |

## Using a skill

### Option 1: Upload to an app (no technical setup)

Apps like Claude (desktop and web) let you upload a skill as a `.zip` file.

1. On this repository's GitHub page, click **Code → Download ZIP** and unzip it.
2. Find the skill you want in the `skills` folder.
3. Compress that skill's folder (for example `skills/pdf-summarizer`) into a `.zip`
   file. On most computers: right-click the folder and choose *Compress* or
   *Send to → Compressed folder*.
4. In the app, open the skills section of the settings and upload the `.zip` file.

### Option 2: Copy the folder by hand

Copy the skill's folder into the skills folder of your assistant. Common locations:

| Assistant      | For all your projects | For one project   |
| -------------- | --------------------- | ----------------- |
| Claude Code    | `~/.claude/skills/`   | `.claude/skills/` |
| Codex          | `~/.agents/skills/`   | `.agents/skills/` |
| Gemini CLI     | `~/.gemini/skills/`   | `.gemini/skills/` |
| Cursor         | `~/.cursor/skills/`   | `.cursor/skills/` |
| GitHub Copilot | `~/.copilot/skills/`  | `.github/skills/` |

`~` is your home folder. Many assistants also read the shared `.agents/skills/` folder.
Tools change these locations from time to time, so check your assistant's
documentation if a skill does not show up.

### Option 3: Install script (macOS, Linux, Windows with WSL or Git Bash)

```bash
git clone https://github.com/adiacov/ai-skills.git
cd ai-skills

scripts/install.sh --list                        # show supported assistants
scripts/install.sh claude                        # install all skills for Claude Code
scripts/install.sh codex pdf-summarizer          # install one skill for Codex
scripts/install.sh cursor --project ~/my-app     # install into a single project
scripts/install.sh --dir ~/some/skills/folder    # any other assistant
scripts/install.sh claude --uninstall            # remove them again
```

By default the script creates links instead of copies, so running `git pull` updates
every installed skill at once. Use `--copy` for independent copies.

To build upload-ready `.zip` files for Option 1, run `scripts/package.sh`. The
files are written to `dist/`.

## Creating a new skill

**With an AI agent (recommended).** Open this repository in an agent such as Claude
Code or Codex and describe what you need, for example:

> Create a skill that turns my meeting notes into a short summary with decisions and
> action items.

The agent follows [AGENTS.md](AGENTS.md): it asks a few questions, writes the skill
from the template, checks it, and adds it to the catalog above.

**By hand.**

1. Copy `templates/skill` to `skills/<your-skill-name>` (lowercase words joined by
   hyphens).
2. Edit `SKILL.md`: set `name` to the folder name, write a clear `description`, and
   fill in the instructions.
3. Run `scripts/validate.sh` to check the format.

A good description is the most important part. It should say what the skill does and
when to use it, using the words people would naturally say.

## Repository structure

```
ai-skills/
├── skills/              The skills, one folder each
├── templates/skill/     Starting point for new skills
├── scripts/
│   ├── validate.sh      Checks that every skill is correctly formatted
│   ├── install.sh       Installs skills into an assistant
│   └── package.sh       Creates .zip files for uploading
├── AGENTS.md            Instructions for AI agents working in this repository
├── CLAUDE.md            Points Claude Code to AGENTS.md
├── CHANGELOG.md         History of notable changes
└── LICENSE              MIT license
```

Every change is checked automatically on GitHub. To run the same check before each
commit on your machine, enable the included hook once:

```bash
git config core.hooksPath .githooks
```

## Contributing

This is a personal collection, but suggestions are welcome. Feel free to open an issue
to report a problem or propose an improvement to a skill.

## License

[MIT](LICENSE). You are free to use, change and share these skills.
