# Copyright 2026 The OpenTacit Authors
# SPDX-License-Identifier: Apache-2.0

HUGO ?= hugo
TACIT ?= ../tacit
DOCS ?= ../tacit-internal-docs

.PHONY: preview announcement serve build drafts site check clean

## preview: write the announcement from ../tacit-internal-docs, then serve it.
## The post is never committed — see hack/announcement.sh.
preview: announcement serve

## announcement: write the announcement into content/posts/ for review
announcement:
	./hack/announcement.sh $(DOCS)

## serve: the local preview, drafts included, at http://localhost:1313
serve:
	$(HUGO) server -D --disableFastRender

## build: what CI publishes — no drafts, minified, real base URL
build:
	$(HUGO) --minify --baseURL "https://blog.opentacit.com/"

## drafts: build including drafts, for looking at one before it goes out
drafts:
	$(HUGO) -D --minify

## site: re-take the landing page's chrome — stylesheet, fonts, head prelude,
## masthead and theme toggle — from the tacit working copy next door
site:
	./hack/sync-site.sh $(TACIT)

## check: both drifts. The chrome here against the landing page it came from,
## and the built page against the chrome.
check:
	./hack/sync-site.sh --check $(TACIT)
	./hack/check-masthead.sh

clean:
	rm -rf public resources
