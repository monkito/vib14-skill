#!/usr/bin/env bash
# Validate SKILL.md frontmatter against the contract in
# clash/docs/plans/2026-05-18-clawhub-skill-package.md §2.2.
#
# Schema per agentskills.io/specification:
#   - top-level required: name, description
#   - top-level optional: license, version (workflow-extracted for publish)
#   - metadata is a flat string map; we use metadata.{homepage, emoji}
#
# Rules:
#   - all 5 required leaves present (name, description, version,
#     metadata.homepage, metadata.emoji)
#   - version is strict semver X.Y.Z
#   - every value is a single-line scalar (no |, >, double-quoted, or
#     backslash-escaped multi-line forms)
#
# Exit codes: 0 ok / 2 frontmatter invalid / 3 file missing
set -euo pipefail

file="${1:-SKILL.md}"

if [ ! -f "$file" ]; then
  echo "::error::file not found: $file"
  exit 3
fi

# Extract frontmatter block: lines between the first two `---` lines.
fm=$(awk '
  BEGIN { in_fm = 0; seen = 0 }
  /^---$/ {
    if (in_fm == 0 && seen == 0) { in_fm = 1; seen = 1; next }
    if (in_fm == 1) { exit }
  }
  in_fm == 1 { print }
' "$file")

if [ -z "$fm" ]; then
  echo "::error::no YAML frontmatter found (expected --- ... --- block at top of $file)"
  exit 2
fi

fail=0

# Each entry: <display-path>|<regex-anchored-to-the-required-line>
required=(
  "name|^name:[[:space:]]+.+$"
  "description|^description:[[:space:]]+.+$"
  "version|^version:[[:space:]]+[0-9]+\\.[0-9]+\\.[0-9]+$"
  "metadata|^metadata:[[:space:]]*$"
  "metadata.homepage|^[[:space:]]{2}homepage:[[:space:]]+.+$"
  "metadata.emoji|^[[:space:]]{2}emoji:[[:space:]]+.+$"
)

for entry in "${required[@]}"; do
  IFS='|' read -r path regex <<<"$entry"
  if ! grep -qE "$regex" <<<"$fm"; then
    echo "::error::frontmatter missing or malformed: ${path}"
    fail=1
  fi
done

# Forbidden-character check on every leaf line (key: value).
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*([a-z_][a-z0-9_-]*):[[:space:]]+(.+)$ ]]; then
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"
    case "$value" in
      *'|'*|*'>'*|*'"'*|*'\'*)
        echo "::error::field '${key}' contains forbidden char (|, >, \", or \\) — single-line scalar only"
        fail=1
        ;;
    esac
  fi
done <<<"$fm"

if [ "$fail" -ne 0 ]; then
  exit 2
fi

version=$(grep -E '^version:' <<<"$fm" | head -1 | sed -E 's/^version:[[:space:]]*//')
echo "frontmatter ok (version=$version)"
