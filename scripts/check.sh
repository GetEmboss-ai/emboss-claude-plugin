#!/usr/bin/env bash
# Repo-wide checks: JSON validity + required fields, no em dashes, plugin validate.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json .mcp.json; do
  python3 -c "import json,sys; json.load(open('$f'))" || { echo "invalid JSON: $f"; fail=1; }
done
python3 - <<'EOF' || fail=1
import json, sys
p = json.load(open(".claude-plugin/plugin.json"))
m = json.load(open(".claude-plugin/marketplace.json"))
s = json.load(open(".mcp.json"))
assert p["name"] == "emboss", "plugin name must be emboss"
assert m["name"] == "getemboss", "marketplace name must be getemboss"
assert not p["name"].startswith(("claude-", "anthropic-")) and not m["name"].startswith(("claude-", "anthropic-"))
assert s["mcpServers"]["emboss"]["url"] == "https://api.getemboss.ai/mcp"
assert s["mcpServers"]["emboss"]["type"] == "http"
print("manifests ok")
EOF
if grep -rIl $'\xe2\x80\x94' --exclude-dir=.git --exclude-dir=node_modules . ; then echo "em dash found"; fail=1; fi
# NOTE: --strict is added in Task 2 once skills/ has real content.
if command -v claude >/dev/null 2>&1; then claude plugin validate . || fail=1; else echo "claude CLI not found; skipping plugin validate"; fi
exit $fail
