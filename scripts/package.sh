#!/usr/bin/env bash
# Package skills as .zip files for apps that install skills by upload
# (for example the Claude desktop and web apps).
#
# Usage: scripts/package.sh [skill ...]
#   With no arguments, packages every skill. Output goes to dist/<skill>.zip.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
DIST_DIR="$ROOT/dist"

skills=("$@")
if (( ${#skills[@]} == 0 )); then
    shopt -s nullglob
    for d in "$SKILLS_DIR"/*/; do skills+=("$(basename "$d")"); done
    shopt -u nullglob
fi

if (( ${#skills[@]} == 0 )); then
    echo "No skills found in skills/. Nothing to package."
    exit 0
fi

"$ROOT/scripts/validate.sh" "${skills[@]/#/$SKILLS_DIR/}" > /dev/null \
    || { echo "Validation failed; run scripts/validate.sh for details." >&2; exit 1; }

mkdir -p "$DIST_DIR"
cd "$SKILLS_DIR"

for skill in "${skills[@]}"; do
    out="$DIST_DIR/$skill.zip"
    rm -f "$out"
    if command -v zip > /dev/null; then
        zip -qr "$out" "$skill" -x '*/.DS_Store' '*/__pycache__/*'
    else
        python3 -m zipfile -c "$out" "$skill"
    fi
    echo "Created dist/$skill.zip"
done
