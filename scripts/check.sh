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
# same directory. To also strictly validate the plugin manifest plus the skills,
# agents, and commands it points at, validate a scratch copy of the repo with
# marketplace.json removed so the CLI falls through to the plugin manifest instead.
if command -v claude >/dev/null 2>&1; then
  claude plugin validate . --strict || fail=1
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  cp -R . "$tmpdir/repo"
  rm -rf "$tmpdir/repo/.git"
  rm -f "$tmpdir/repo/.claude-plugin/marketplace.json"
  claude plugin validate "$tmpdir/repo" --strict || fail=1
  rm -rf "$tmpdir"
  trap - EXIT
else
  echo "claude CLI not found; skipping plugin validate"
fi
exit $fail
