#!/usr/bin/env bash
# Copyright 2026 The OpenTacit Authors
# SPDX-License-Identifier: Apache-2.0

# Fail if the masthead that reaches a reader is not the one taken from the
# landing page.
#
#   ./hack/check-masthead.sh
#
# sync-site.sh keeps the partial current with the tacit working copy; this keeps
# the BUILT PAGE current with the partial, which is a different failure. A
# template that stops including it, an edit to the generated file, a Hugo
# version that renders it differently — none of those touch the partial, and all
# of them put a lookalike header back on the site.
#
# It needs no browser and no tacit checkout, so CI runs it on every push. The
# build here is deliberately not minified: minification strips the quotes the
# comparison is made of.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hugo="${HUGO:-hugo}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

"$hugo" --quiet -s "$here" -d "$tmp/site" --baseURL "https://blog.opentacit.com/" >/dev/null

python3 - "$tmp/site/index.html" "$here/layouts/partials/site-masthead.html" <<'PY'
import re, sys
page = open(sys.argv[1], encoding="utf-8").read()
partial = open(sys.argv[2], encoding="utf-8").read()

# The partial without the generator's note, which is a Hugo comment and never
# reaches the page.
want = re.sub(r'^\{\{/\*.*?\*/\}\}\s*', '', partial, flags=re.S).strip()

try:
    i = page.index('<div class="site-masthead">')
except ValueError:
    raise SystemExit("check-masthead: the built page has no masthead at all")
depth, j = 0, i
for m in re.finditer(r'<(/?)div\b', page[i:]):
    depth += -1 if m.group(1) else 1
    if depth == 0:
        j = page.index('>', i + m.end() - 1) + 1
        break
got = page[i:j].strip()

if got != want:
    print("check-masthead: the built page's masthead is not the landing page's.", file=sys.stderr)
    print("run ./hack/sync-site.sh, or put the partial back in the template.", file=sys.stderr)
    import difflib
    for line in list(difflib.unified_diff(want.splitlines(), got.splitlines(),
                                          "site-masthead.html", "built page", lineterm=""))[:40]:
        print(line, file=sys.stderr)
    raise SystemExit(1)
print("the built page carries the landing page's masthead")
PY
