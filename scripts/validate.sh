#!/usr/bin/env bash
# Validate every skill in skills/ against the Agent Skills (SKILL.md) format.
#
# Usage: scripts/validate.sh [skill-dir ...]
#   With no arguments, validates every directory in skills/.
#
# Errors fail the run (exit 1). Warnings are printed but do not fail it.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"

KNOWN_KEYS=" name description license compatibility metadata allowed-tools "
MAX_NAME=64
MAX_DESCRIPTION=1024
MAX_COMPATIBILITY=500
MAX_BODY_LINES=500

errors=0
warnings=0

error() { echo "  ERROR: $*"; errors=$((errors + 1)); }
warn()  { echo "  WARN:  $*"; warnings=$((warnings + 1)); }

# Print the value of a top-level frontmatter key, joining folded/multi-line values.
frontmatter_value() {
    local key="$1" file="$2"
    awk -v key="$key" '
        NR == 1 { next }
        /^---[[:space:]]*$/ { exit }
        capturing {
            if ($0 ~ /^[[:space:]]+/) { sub(/^[[:space:]]+/, ""); out = out (out == "" ? "" : " ") $0; next }
            exit
        }
        $0 ~ "^" key ":" {
            val = substr($0, length(key) + 2)
            sub(/^[[:space:]]+/, "", val); sub(/[[:space:]]+$/, "", val)
            if (val ~ /^[>|][-+]?$/ || val == "") { capturing = 1; next }
            out = val; exit
        }
        END {
            if (out ~ /^".*"$/ || out ~ /^'\''.*'\''$/) out = substr(out, 2, length(out) - 2)
            print out
        }
    ' "$file"
}

validate_skill() {
    local dir="${1%/}" name file
    name="$(basename "$dir")"
    file="$dir/SKILL.md"
    echo "$name"

    if [[ ! -f "$file" ]]; then
        error "missing SKILL.md"
        return
    fi

    if [[ "$(head -n 1 "$file")" != "---" ]]; then
        error "SKILL.md must start with a '---' frontmatter line"
        return
    fi

    local fm_end
    fm_end="$(awk 'NR > 1 && /^---[[:space:]]*$/ { print NR; exit }' "$file")"
    if [[ -z "$fm_end" ]]; then
        error "frontmatter is not closed with a '---' line"
        return
    fi

    # name
    local fm_name
    fm_name="$(frontmatter_value name "$file")"
    if [[ -z "$fm_name" ]]; then
        error "frontmatter is missing 'name'"
    else
        [[ "$fm_name" == "$name" ]] || error "name '$fm_name' does not match directory name '$name'"
        (( ${#fm_name} <= MAX_NAME )) || error "name is longer than $MAX_NAME characters"
        [[ "$fm_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] \
            || error "name must use lowercase letters, digits and single hyphens (no leading/trailing hyphen)"
    fi

    # description
    local fm_desc
    fm_desc="$(frontmatter_value description "$file")"
    if [[ -z "$fm_desc" ]]; then
        error "frontmatter is missing 'description'"
    else
        (( ${#fm_desc} <= MAX_DESCRIPTION )) || error "description is ${#fm_desc} characters (max $MAX_DESCRIPTION)"
        (( ${#fm_desc} >= 40 )) || warn "description is very short; say what the skill does and when to use it"
    fi

    # compatibility
    local fm_compat
    fm_compat="$(frontmatter_value compatibility "$file")"
    if [[ -n "$fm_compat" ]] && (( ${#fm_compat} > MAX_COMPATIBILITY )); then
        error "compatibility is longer than $MAX_COMPATIBILITY characters"
    fi

    # unknown top-level keys hurt portability across agents
    local key
    while IFS= read -r key; do
        [[ "$KNOWN_KEYS" == *" $key "* ]] || warn "frontmatter key '$key' is not part of the shared spec; some agents may ignore it"
    done < <(sed -n "2,$((fm_end - 1))p" "$file" | grep -E '^[A-Za-z0-9_-]+:' | cut -d: -f1)

    # body size
    local total body
    total="$(wc -l < "$file")"
    body=$((total - fm_end))
    (( body > 0 )) || error "SKILL.md has no instructions after the frontmatter"
    (( body <= MAX_BODY_LINES )) || warn "body is $body lines; keep it under $MAX_BODY_LINES and move detail into references/"

    # placeholder text left over from the template
    grep -q 'One or two sentences saying what this skill does' "$file" \
        && error "description still contains template placeholder text"
}

if (( $# > 0 )); then
    targets=("$@")
else
    shopt -s nullglob
    targets=("$SKILLS_DIR"/*/)
    shopt -u nullglob
fi

if (( ${#targets[@]} == 0 )); then
    echo "No skills found in skills/. Nothing to validate."
    exit 0
fi

for target in "${targets[@]}"; do
    validate_skill "$target"
done

echo
echo "Checked ${#targets[@]} skill(s): $errors error(s), $warnings warning(s)."
(( errors == 0 ))
