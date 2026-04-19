#!/usr/bin/env bash
# concat.sh <lang>
#   Concatenate chapter files into a single whitepaper-<lang>.md for Pandoc.
#   Strips per-chapter YAML frontmatter (PDF uses assets/pdf/metadata-<lang>.yaml).
#   Strips <script type="application/ld+json"> and AI-friendly HTML comment blocks.
#   Strips per-chapter navigation footer lines (starting with "**導覽**" or "**Nav**").

set -euo pipefail

LANG_DIR="${1:-zh-TW}"
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LANG_PATH="${BASE_DIR}/${LANG_DIR}"

if [[ ! -d "${LANG_PATH}" ]]; then
  echo "Language directory not found: ${LANG_PATH}" >&2
  exit 1
fi

# Deterministic order: ch01..ch12, then appendix-a..d
FILES=(
  "${LANG_PATH}/ch01-"*.md
  "${LANG_PATH}/ch02-"*.md
  "${LANG_PATH}/ch03-"*.md
  "${LANG_PATH}/ch04-"*.md
  "${LANG_PATH}/ch05-"*.md
  "${LANG_PATH}/ch06-"*.md
  "${LANG_PATH}/ch07-"*.md
  "${LANG_PATH}/ch08-"*.md
  "${LANG_PATH}/ch09-"*.md
  "${LANG_PATH}/ch10-"*.md
  "${LANG_PATH}/ch11-"*.md
  "${LANG_PATH}/ch12-"*.md
  "${LANG_PATH}/appendix-"*.md
)

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  awk '
    BEGIN { fm=0; inld=0 }
    # Strip YAML frontmatter (between first two "---" lines at file head)
    NR==1 && /^---[[:space:]]*$/ { fm=1; next }
    fm==1 && /^---[[:space:]]*$/ { fm=0; next }
    fm==1 { next }
    # Strip AI-friendly HTML comment blocks
    /^<!--[[:space:]]*AI-friendly/ { inld=1; next }
    inld==1 && /^-->/ { inld=0; next }
    inld==1 { next }
    # Strip raw JSON-LD script blocks
    /^<script type="application\/ld\+json">/ { inld=1; next }
    inld==1 && /^<\/script>/ { inld=0; next }
    inld==1 { next }
    # Strip per-chapter navigation footers
    /^\*\*導覽\*\*/ { next }
    /^\*\*Nav\*\*/ { next }
    { print }
  ' "$f"
  echo ""
  echo "\\newpage"
  echo ""
done
