#!/usr/bin/env bash
# Fails if documentation, spec or collection files contain example IDs or
# credential values that are not obvious placeholders.
#
# Placeholders that pass:
#   UUID (optionally prefixed, e.g. acc_): 00000000-0000-0000-0000-000000000000
#     (only the last 4 hex digits may vary, e.g. ...000000000001)
#   UUID from RFC 4122 examples:           123e4567-e89b-12d3-a456-426614174000
#   ObjectId:                              000000000000000000000000 (last 4 may vary)
#   Credentials:                           YOUR_API_KEY, YOUR_CLIENT_SECRET, {{variable}}, ...
#
# Exact values that are known to be fine can be listed, one per line, in
# .example-ids-allowlist at the repository root (lines starting with # are ignored).
#
# Usage: scripts/check-example-ids.sh [file ...]
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [ "$#" -gt 0 ]; then
  files=("$@")
else
  files=()
  while IFS= read -r f; do files+=("$f"); done < <(
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git ls-files -- '*.json' '*.md' '*.yaml' '*.yml'
    else
      find . -type f \( -name '*.json' -o -name '*.md' -o -name '*.yaml' -o -name '*.yml' \) \
        -not -path './.git/*' -not -path '*/node_modules/*' | sed 's|^\./||'
    fi
  )
fi
[ "${#files[@]}" -eq 0 ] && { echo "check-example-ids: no files to scan"; exit 0; }

allow=()
if [ -f .example-ids-allowlist ]; then
  while IFS= read -r l; do
    l="${l%%#*}"; l="${l//[[:space:]]/}"
    [ -n "$l" ] && allow+=("$l")
  done < .example-ids-allowlist
fi

is_allowed() {
  local v="$1" a
  for a in "${allow[@]+"${allow[@]}"}"; do [ "$v" = "$a" ] && return 0; done
  return 1
}

HEX='[0-9a-fA-F]'
UUID_RE="([a-z0-9]{2,8}_)?${HEX}{8}-${HEX}{4}-${HEX}{4}-${HEX}{4}-${HEX}{12}"
OID_RE="\b[0-9a-f]{24}\b"
CRED_RE="(secret|password|passwd|api_key|apikey|_key|token)\\\\?\"[[:space:]]*:[[:space:]]*\\\\?\"[0-9a-fA-F]{16,}\\\\?\""
# Tool metadata that is not example content (Postman export fields).
SKIP_RE='"_postman_id"|"_collection_link"|"_exporter_id"'

uuid_placeholder='^([a-z0-9]{2,8}_)?(00000000-0000-0000-0000-00000000[0-9a-fA-F]{4}|123e4567-e89b-12d3-a456-426614174000)$'
oid_placeholder='^0{20}[0-9a-f]{4}$'

found=0
report() { echo "$1: $2"; found=$((found + 1)); }

scan() { # pattern placeholder-regex label
  local pat="$1" ok="$2" label="$3" loc line m
  while IFS= read -r hit; do
    loc="${hit%%:*}"; hit="${hit#*:}"; line="${hit%%:*}"; hit="${hit#*:}"
    printf '%s\n' "$hit" | grep -qE "$SKIP_RE" && continue
    while IFS= read -r m; do
      [ -z "$m" ] && continue
      [ -n "$ok" ] && printf '%s\n' "$m" | grep -qE "$ok" && continue
      is_allowed "$m" && continue
      report "$loc:$line" "$label $m"
    done < <(printf '%s\n' "$hit" | grep -oE "$pat" || true)
  done < <(grep -HnE "$pat" -- "${files[@]}" 2>/dev/null || true)
}

scan "$UUID_RE" "$uuid_placeholder" "non-placeholder UUID"
scan "$OID_RE" "$oid_placeholder" "non-placeholder ObjectId"
scan "$CRED_RE" "" "credential-like value"

if [ "$found" -gt 0 ]; then
  echo
  echo "check-example-ids: $found value(s) found. Examples must use fictitious placeholders"
  echo "(see CONTRIBUTING.md). Add an exact value to .example-ids-allowlist only if it is"
  echo "known not to identify anything real."
  exit 1
fi
echo "check-example-ids: OK (${#files[@]} files scanned)"
