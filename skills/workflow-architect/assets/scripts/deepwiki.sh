#!/bin/bash
# deepwiki.sh — DeepWiki MCP HTTP wrapper for workflow-architect
# Calls DeepWiki's Streamable HTTP MCP endpoint directly via curl.
# No MCP configuration or session restart required.
#
# Usage:
#   deepwiki.sh ask "owner/repo" "question"
#   deepwiki.sh ask '["owner/repo1","owner/repo2"]' "question"   # cross-repo (max 10)
#   deepwiki.sh structure "owner/repo"
#   deepwiki.sh contents "owner/repo"
#
# Environment:
#   DEEPWIKI_RETRIES   — max retry attempts on 429 (default: 3)
#   DEEPWIKI_CACHE_DIR — cache directory path (default: .workflow/deepwiki-cache)

set -euo pipefail

ENDPOINT="https://mcp.deepwiki.com/mcp"
MAX_RETRIES="${DEEPWIKI_RETRIES:-3}"
RETRY_DELAYS=(10 30 60)
CACHE_DIR="${DEEPWIKI_CACHE_DIR:-.workflow/deepwiki-cache}"

# ── helpers ──────────────────────────────────────────────────────

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

call_mcp() {
  local tool_name="$1"
  local arguments_json="$2"

  local payload="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"${tool_name}\",\"arguments\":${arguments_json}}}"

  curl -s -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d "$payload" 2>&1
}

extract_text() {
  # Extract the text field from MCP SSE JSON-RPC response
  # 1. Remove SSE framing (event: message\ndata: prefix)
  # 2. Extract the "text" value from JSON
  # 3. Unescape JSON string escapes
  local raw
  raw=$(cat)
  # Strip SSE envelope
  raw=$(echo "$raw" | sed 's/^event: message//' | sed 's/^data: //' | tr -d '\r')
  # Extract text content between first "text":" and the closing "}]
  local text
  text=$(echo "$raw" | sed 's/.*"text":"//' | sed 's/"}],"structuredContent".*//')
  # Unescape JSON
  printf '%b' "$text" | sed 's/\\"/"/g'
}

check_429() {
  grep -q "429 Too Many Requests" <<< "$1"
}

cache_key() {
  # Generate a filesystem-safe cache key
  local input="$1"
  echo "$input" | sed 's/[^a-zA-Z0-9_-]/_/g' | cut -c1-80
}

# ── subcommands ──────────────────────────────────────────────────

cmd_ask() {
  local repo="$1"
  local question="$2"
  local cache_file=""

  # Build repoName JSON value
  local repo_json
  if [[ "$repo" == \[* ]]; then
    repo_json="$repo"
  else
    repo_json="\"$repo\""
  fi

  local escaped_q
  escaped_q=$(json_escape "$question")

  # Check cache
  if [ -n "$CACHE_DIR" ]; then
    local key
    key=$(cache_key "${repo}__${question}")
    cache_file="${CACHE_DIR}/${key}.md"
    if [ -f "$cache_file" ]; then
      echo "[DeepWiki] Cache hit: $cache_file" >&2
      cat "$cache_file"
      return 0
    fi
  fi

  # Call with retry
  local arguments="{\"repoName\":${repo_json},\"question\":\"${escaped_q}\"}"

  for i in $(seq 0 $((MAX_RETRIES - 1))); do
    local result
    result=$(call_mcp "ask_question" "$arguments")

    if check_429 "$result"; then
      if [ $i -lt $((MAX_RETRIES - 1)) ]; then
        echo "[DeepWiki] 429 rate limited, retry in ${RETRY_DELAYS[$i]}s... (attempt $((i+2))/$MAX_RETRIES)" >&2
        sleep "${RETRY_DELAYS[$i]}"
      else
        echo "[DeepWiki] Failed after $MAX_RETRIES attempts" >&2
        return 1
      fi
    else
      local text
      text=$(echo "$result" | extract_text)

      # Write to cache
      if [ -n "$CACHE_DIR" ] && [ -n "$cache_file" ]; then
        mkdir -p "$CACHE_DIR"
        echo "$text" > "$cache_file"
      fi

      echo "$text"
      return 0
    fi
  done
  return 1
}

cmd_structure() {
  local repo="$1"
  local arguments="{\"repoName\":\"$repo\"}"
  local result
  result=$(call_mcp "read_wiki_structure" "$arguments")
  echo "$result" | extract_text
}

cmd_contents() {
  local repo="$1"
  local arguments="{\"repoName\":\"$repo\"}"
  local result
  result=$(call_mcp "read_wiki_contents" "$arguments")
  echo "$result" | extract_text
}

# ── main ─────────────────────────────────────────────────────────

usage() {
  echo "Usage:" >&2
  echo "  $0 ask <owner/repo | '[\"repo1\",\"repo2\"]'> <question>" >&2
  echo "  $0 structure <owner/repo>" >&2
  echo "  $0 contents <owner/repo>" >&2
  exit 1
}

if [ $# -lt 2 ]; then
  usage
fi

CMD="$1"
shift

case "$CMD" in
  ask)
    [ $# -lt 2 ] && usage
    cmd_ask "$1" "$2"
    ;;
  structure)
    cmd_structure "$1"
    ;;
  contents)
    cmd_contents "$1"
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    usage
    ;;
esac
