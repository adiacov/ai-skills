#!/usr/bin/env bash
# Install skills from this repository into an AI agent's skills directory.
#
# Usage: scripts/install.sh <agent> [options] [skill ...]
#        scripts/install.sh --list
#
# Agents:   claude, codex, gemini, cursor, copilot, agents (shared .agents/ folder)
# Options:
#   --project DIR   install into project DIR instead of your home directory
#   --dir DIR       install into this exact skills directory (any agent)
#   --copy          copy files instead of creating symlinks
#   --force         replace skills that already exist at the destination
#   --uninstall     remove the skills instead of installing them
#   --list          show supported agents and their skills directories
#
# With no skill names, every skill in skills/ is installed.
# Symlinks (the default) keep installed skills in sync with this repository.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"

# Skills directories per agent: "<global path>|<path inside a project>".
# Agents change these from time to time; check your agent's documentation
# and use --dir if yours differs.
declare -A AGENT_PATHS=(
    [claude]="$HOME/.claude/skills|.claude/skills"
    [codex]="$HOME/.agents/skills|.agents/skills"
    [gemini]="$HOME/.gemini/skills|.gemini/skills"
    [cursor]="$HOME/.cursor/skills|.cursor/skills"
    [copilot]="$HOME/.copilot/skills|.github/skills"
    [agents]="$HOME/.agents/skills|.agents/skills"
)

usage() { sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

list_agents() {
    printf '%-9s %-32s %s\n' AGENT GLOBAL PROJECT
    local agent
    for agent in claude codex gemini cursor copilot agents; do
        printf '%-9s %-32s %s\n' "$agent" "${AGENT_PATHS[$agent]%%|*}" "${AGENT_PATHS[$agent]#*|}"
    done
}

agent="" project="" dest="" mode=link force=0 uninstall=0
skills=()

while (( $# > 0 )); do
    case "$1" in
        -h|--help)   usage; exit 0 ;;
        --list)      list_agents; exit 0 ;;
        --project)   project="${2:?--project needs a directory}"; shift ;;
        --dir)       dest="${2:?--dir needs a directory}"; shift ;;
        --copy)      mode=copy ;;
        --force)     force=1 ;;
        --uninstall) uninstall=1 ;;
        -*)          echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
        *)
            if [[ -z "$agent" && -z "$dest" && -n "${AGENT_PATHS[$1]+x}" ]]; then
                agent="$1"
            else
                skills+=("$1")
            fi
            ;;
    esac
    shift
done

if [[ -z "$dest" ]]; then
    if [[ -z "$agent" ]]; then
        echo "Choose an agent or pass --dir." >&2
        usage >&2
        exit 2
    fi
    if [[ -n "$project" ]]; then
        dest="$(cd "$project" && pwd)/${AGENT_PATHS[$agent]#*|}"
    else
        dest="${AGENT_PATHS[$agent]%%|*}"
    fi
fi

if (( ${#skills[@]} == 0 )); then
    shopt -s nullglob
    for d in "$SKILLS_DIR"/*/; do skills+=("$(basename "$d")"); done
    shopt -u nullglob
fi

if (( ${#skills[@]} == 0 )); then
    echo "No skills found in skills/. Nothing to do."
    exit 0
fi

mkdir -p "$dest"
echo "Destination: $dest"

for skill in "${skills[@]}"; do
    src="$SKILLS_DIR/$skill"
    target="$dest/$skill"

    if [[ ! -f "$src/SKILL.md" ]]; then
        echo "  skip   $skill (not found in skills/)"
        continue
    fi

    if (( uninstall )); then
        if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
            rm "$target"; echo "  remove $skill"
        elif [[ -e "$target" && $force -eq 1 ]]; then
            rm -rf "$target"; echo "  remove $skill"
        elif [[ -e "$target" ]]; then
            echo "  skip   $skill (not a link to this repository; use --force to remove)"
        fi
        continue
    fi

    if [[ -L "$target" && "$(readlink "$target")" == "$src" && "$mode" == link ]]; then
        echo "  ok     $skill (already linked)"
        continue
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        if (( ! force )); then
            echo "  skip   $skill (already exists; use --force to replace)"
            continue
        fi
        rm -rf "$target"
    fi

    if [[ "$mode" == link ]]; then
        ln -s "$src" "$target"; echo "  link   $skill"
    else
        cp -R "$src" "$target"; echo "  copy   $skill"
    fi
done
