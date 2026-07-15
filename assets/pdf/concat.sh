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

# Deterministic order: all chNN-*.md in numeric order, then all appendix-*.md.
# Globbed dynamically (sort -V) so new chapters are picked up automatically —
# do NOT hardcode the chapter list (ch13 was once dropped from the PDF that way).
mapfile -t CHAPTERS   < <(ls "${LANG_PATH}"/ch*-*.md        2>/dev/null | sort -V)
mapfile -t APPENDICES < <(ls "${LANG_PATH}"/appendix-*-*.md 2>/dev/null | sort -V)
FILES=("${CHAPTERS[@]}" "${APPENDICES[@]}")

if [[ ${#CHAPTERS[@]} -eq 0 ]]; then
  echo "No chapter files (ch*-*.md) found in ${LANG_PATH}" >&2
  exit 1
fi

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
    /^\{% raw %\}[[:space:]]*$/ { next }
    /^\{% endraw %\}[[:space:]]*$/ { next }
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
