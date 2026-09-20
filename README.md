# OpenTacit — blog

The project's blog: a Hugo site, built by GitHub Actions and served by GitHub
Pages at **https://blog.opentacit.com**.

It is separate from [`../tacit`](../tacit) because none of it is the product,
and separate from the registry because the registry is a home server: a post
should still be readable when that machine is off.

## Writing a post

```sh
hugo new content posts/some-post.md    # or copy an existing file
make serve                             # http://localhost:1313, drafts included
```

The archetype starts every post with `draft: true`. A draft is visible in the
local preview, marked as one, and never reaches the live site — CI fails the
build if one gets through. Publishing is deleting that line and merging to
`main`.

Front matter is four fields: `title`, `date`, `description` (one sentence, shown
on the index and in search results) and `draft`. A post lives at `/<slug>/`,
with no date and no section in the address, so nothing about it has to change
later.

## The look

One stylesheet, assembled at build time from two files:

- `assets/css/tokens.css` — **generated**, never edited. `hack/sync-tokens.sh`
  copies the palette out of `../tacit/internal/ui/assets/app.css`, and records
  the commit it came from.
- `assets/css/blog.css` — every rule the site has, written against those tokens.

Read the header of `app.css` before changing anything visual, and the header of
`blog.css` for which of its rules this site keeps and which one it is exempt
from. A hex literal in `blog.css` is a bug: the palette has one source, and the
reason is that two surfaces of one product drift apart a shade at a time.

```sh
make tokens    # re-copy after the palette changes next door
make check     # fail if this copy has drifted
```

`make check` needs the tacit working copy beside this one. CI cannot run it —
the two repositories are separate — so it is a local target, worth running when
you have just changed `app.css`.

The fonts under `static/fonts/` are copies of the registry's, with their
licences. Nothing is fetched at runtime: no CDN, no icon font, no framework.

## How it is served

`static/CNAME` sets the custom domain. The DNS record for `blog` is a CNAME to
`opentacit.github.io`, outside the Cloudflare proxy, so GitHub issues and renews
the certificate and the zone's rules never touch this site. The zone itself
carries nothing for the blog: `opentacit.com/blog` is not an address here.

The one hazard worth knowing: the zone has a wildcard record, so if the `blog`
CNAME is ever deleted the name keeps resolving — straight to the registry, which
answers 404. It fails quietly rather than loudly, which is why
`../tacit-deployment/cloudflare/verify-blog.sh` exists: it checks the record,
the certificate's issuer, the feed and the 404, and says which one broke.

## The placeholder

`content/posts/setting-up.md` exists to prove the site resolves — the domain,
the certificate, the build, the feed and a post's address. It publishes, so the
index is not empty while the wiring is being checked. Delete it once the
announcement goes up; nothing else refers to it.

The announcement itself is not in this repository. It stays in
`tacit-internal-docs/docs/distribution/blog-introducing-tacit.md` until it is
ready to publish, because a public repository's history keeps a file that a
later commit deletes. Its claims about behaviour are worth checking against the
user guide on the day it goes out, and every link in its closing section points
at `github.com/opentacit/tacit`, which 404s until that repository is public.

## Setting it up, once

1. Create `opentacit/blog` on GitHub and push this repository to it.
2. Settings → Pages → Source: **GitHub Actions**.
3. Verify the domain for the org: Settings → Pages → Add a domain, then the
   `_github-pages-challenge-opentacit` TXT record it gives you. Without this,
   the subdomain can be claimed by somebody else if the repository is ever
   deleted.
4. Add the DNS record in Cloudflare — `blog` CNAME `opentacit.github.io`, **DNS
   only**, no proxy — and wait for GitHub to issue the certificate, which shows
   up as *Enforce HTTPS* going green on the Pages settings page.
5. `../tacit-deployment/cloudflare/verify-blog.sh`.

A private repository needs a paid GitHub plan for Pages to serve it. On a free
org, the source has to be public — which is fine for a blog, and means the name
of the working copy here is the only thing that is "internal" about it.
