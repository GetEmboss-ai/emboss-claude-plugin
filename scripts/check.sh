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
python3 - <<'EOF' || fail=1
import re
t = open("skills/emboss/SKILL.md").read()
m = re.match(r"---\n(.*?)\n---\n", t, re.S)
assert m, "SKILL.md needs YAML frontmatter"
fm = dict(l.split(":", 1) for l in m.group(1).splitlines() if ":" in l)
name = fm["name"].strip(); desc = fm["description"].strip()
assert re.fullmatch(r"[a-z0-9-]{1,64}", name), name
assert "anthropic" not in name and "claude" not in name
assert 0 < len(desc) <= 1024 and "<" not in desc
for trigger in ("fillable", "PDF form", "spreadsheet", "AcroForm"):
    assert trigger.lower() in desc.lower(), "description must mention " + trigger
assert len(t.splitlines()) <= 300, "SKILL.md must stay under 300 lines"
print("skill ok")
EOF
# `claude plugin validate .` validates only the marketplace manifest when both
# .claude-plugin/plugin.json and .claude-plugin/marketplace.json are present in the
# same directory, so validate the plugin manifest separately by path.
if command -v claude >/dev/null 2>&1; then
  claude plugin validate . --strict || fail=1
  claude plugin validate .claude-plugin/plugin.json --strict || fail=1
else
  echo "claude CLI not found; skipping plugin validate"
fi
python3 -c "import json,sys; json.load(open('server.json'))" || { echo "invalid JSON: server.json"; fail=1; }
python3 - <<'EOF' || fail=1
import json
s = json.load(open("server.json"))
assert s["name"].startswith("io.github."), "server.json name must start with io.github."
assert s["remotes"][0]["url"] == "https://api.getemboss.ai/mcp", "server.json remote url must be exact"
print("server.json ok")
EOF
exit $fail
