#!/usr/bin/env bash
# Copyright 2026 The OpenTacit Authors
# SPDX-License-Identifier: Apache-2.0

# Write the announcement into content/posts/ for review, from the copy that
# lives with the distribution plans it serves.
#
#   ./hack/announcement.sh [path-to-tacit-internal-docs]
#
# The post is not in this repository and will not be until it publishes: a
# public repository's history keeps a file that a later commit deletes, so a
# draft committed "just to preview it" is a draft published. .gitignore names
# the path it writes, and `make preview` runs this and then the local server.
#
# What it changes on the way in: the doc's own title and status block come off,
# front matter goes on as a draft, the product takes its public name, and the
# links that pointed into the docs tree point at the public repository. The
# commands keep their names, and "tacit knowledge" is the thing the product is
# named after rather than the product.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docs="${1:-$here/../tacit-internal-docs}"
src="$docs/docs/distribution/blog-introducing-tacit.md"
out="$here/content/posts/introducing-opentacit.md"

[[ -f "$src" ]] || { echo "announcement: no draft at $src" >&2; exit 2; }

python3 - "$src" "$out" <<'PY'
import re, sys
src, out = sys.argv[1], sys.argv[2]
body = open(src).read().split('\n---\n', 1)[1].strip()
body = re.sub(r'\bTacit\b', 'OpenTacit', body)
body = body.replace('OpenTacit knowledge', 'tacit knowledge')
for old, new in {
    '../user-guide/index.md': 'https://github.com/opentacit/tacit/tree/main/docs/user-guide',
    '../user-guide/10-get-started/02-set-up-a-registry.md':
      'https://github.com/opentacit/tacit/blob/main/docs/user-guide/10-get-started/02-set-up-a-registry.md',
    '../user-guide/10-get-started/03-join-your-organization.md':
      'https://github.com/opentacit/tacit/blob/main/docs/user-guide/10-get-started/03-join-your-organization.md',
    '../index.md': 'https://github.com/opentacit/tacit',
}.items():
    body = body.replace('(' + old + ')', '(' + new + ')')
if '../' in body:
    raise SystemExit("announcement: a relative link survived — it would 404 on the blog")
front = '''---
title: "Introducing OpenTacit: your organization's measured playbook for working with AI"
slug: introducing-opentacit
date: 2026-09-20
draft: true
description: "The decisive AI advantage is not the model. It is what your organization has learned about putting models to work — and that knowledge is unwritten, unmeasured, and one departure away from gone."
---

'''
open(out, 'w').write(front + body + '\n')
print("wrote", out)
PY
