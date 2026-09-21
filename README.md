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

The header and the page layout are the landing page's, not a copy of it.
`hack/sync-site.sh` renders that page from the tacit working copy next door
(`make site` there) and takes five things out of the bundle:

- `assets/css/app.css` — the product's stylesheet, whole.
- `static/assets/fonts/` — the faces it names, at the paths it names.
- `layouts/partials/site-head.html` — the head's prelude: favicon, the theme the
  reader last chose, the boot guard, and the critical CSS floor.
- `layouts/partials/site-masthead.html` and `site-theme.html` — the masthead
  markup, byte for byte, and the theme toggle's behaviour.

All five are generated. Editing one is a change that the next sync silently
reverts, and `make check` fails first.

`assets/css/blog.css` is the only hand-written stylesheet, and it holds what a
landing page has no use for: a list of posts and an article. Everything else —
ground, stage, masthead, wordmark, nav, toggle, display type, body column,
close line — comes from `app.css`. The test of any rule you are about to add
there: does `app.css` already say it? This file replaced one that answered yes
about forty times, and still did not match the page it was imitating.

Read the header of `app.css` before changing anything visual, and `blog.css`'s
own header for which of the house rules this surface keeps.

```sh
make site     # re-take the chrome after the landing page changes
make check    # both drifts, see below
```

Two drifts, two guards, and they catch different faults:

- `hack/sync-site.sh --check` — the chrome here against the landing page it came
  from. Needs the tacit checkout beside this one, so CI cannot run it; run it
  when you have just changed `internal/ui`.
- `hack/check-masthead.sh` — the built page against that chrome, which catches a
  template that stops including it. No checkout and no browser, so CI runs it on
  every push.

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
