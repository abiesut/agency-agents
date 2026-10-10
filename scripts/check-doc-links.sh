#!/usr/bin/env bash
#
# check-doc-links.sh — check the markdown links in integrations/*/ docs.
#
# Offline (default): every relative link such as [guide](RESOURCES-AND-TOKENS.md)
# or [readme](../../README.md) must point at a file or directory that exists in
# the repo. Anchors (#section) are stripped before the check.
#
# Online (--online): every http(s) link must also answer with a 2xx/3xx status
# after redirects. Needs curl. Network failures are reported as warnings, not
# errors, so a flaky connection or a blocked host does not fail the check; only
# a definite 404 or 410 does. Use this before merging docs that cite external
# repos, since repos get archived, renamed and deleted.
#
# Scope is integrations/**/*.md, the docs that cite third-party projects.
# Links inside fenced code blocks are ignored.
#
# Usage: ./scripts/check-doc-links.sh [--online]

set -euo pipefail
cd "$(dirname "$0")/.."

ONLINE=0
case "${1:-}" in
  "") ;;
  --online) ONLINE=1 ;;
  *) echo "Usage: $0 [--online]" >&2; exit 2 ;;
esac

command -v python3 >/dev/null 2>&1 || {
  echo "ERROR: python3 is required for the doc links check." >&2
  exit 2
}
if [ "$ONLINE" = 1 ]; then
  command -v curl >/dev/null 2>&1 || {
    echo "ERROR: curl is required for --online." >&2
    exit 2
  }
fi

ONLINE="$ONLINE" python3 - <<'PYEOF'
import os, re, subprocess, sys

online = os.environ["ONLINE"] == "1"
tracked = subprocess.check_output(
    ["git", "ls-files", "integrations/*.md", "integrations/**/*.md"]
).decode().splitlines()
docs = sorted(set(tracked))

LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
errors, warnings = [], []
checked_urls = {}
rel_count = url_count = 0

def probe(url):
    if url in checked_urls:
        return checked_urls[url]
    try:
        out = subprocess.run(
            ["curl", "-s", "-o", "/dev/null", "-L", "--max-time", "20",
             "-w", "%{http_code}", url],
            capture_output=True, text=True, timeout=30,
        ).stdout.strip()
    except (subprocess.TimeoutExpired, OSError):
        out = "000"
    checked_urls[url] = out
    return out

for doc in docs:
    in_fence = False
    for lineno, line in enumerate(open(doc, encoding="utf-8"), 1):
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        for target in LINK.findall(line):
            if target.startswith(("mailto:", "#")):
                continue
            if target.startswith(("http://", "https://")):
                url_count += 1
                if not online:
                    continue
                code = probe(target)
                if code in ("404", "410"):
                    errors.append(f"{doc}:{lineno} {target} -> HTTP {code}")
                elif not code.startswith(("2", "3")):
                    warnings.append(f"{doc}:{lineno} {target} -> HTTP {code} (not verified)")
                continue
            rel_count += 1
            path = target.split("#", 1)[0]
            if not path:
                continue
            resolved = os.path.normpath(os.path.join(os.path.dirname(doc), path))
            if not os.path.exists(resolved):
                errors.append(f"{doc}:{lineno} {target} -> {resolved} does not exist")

for w in warnings:
    print(f"WARN  {w}")
for e in errors:
    print(f"ERROR {e}")
if errors:
    print(f"FAILED: {len(errors)} broken link(s) in {len(docs)} integration doc(s).")
    sys.exit(1)
mode = f"{url_count} external checked online" if online else f"{url_count} external skipped (use --online)"
print(f"PASSED: {len(docs)} integration docs, {rel_count} relative links resolve, {mode}.")
PYEOF
