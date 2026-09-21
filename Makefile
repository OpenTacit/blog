# Copyright 2026 The OpenTacit Authors
# SPDX-License-Identifier: Apache-2.0

HUGO ?= hugo
TACIT ?= ../tacit

# The preview answers on every interface, so a draft can be read on a phone or
# an iPad on the same network rather than only on this machine.
BIND ?= 0.0.0.0
PORT ?= 1313
# Live reload's script carries this address, so a page opened from another
# device against a localhost base URL loads once and then never updates. It
# defaults to this machine's name; override it with the address you actually
# type, e.g. make serve HOST=longreach.tail81644.ts.net
HOST ?= $(shell hostname -f 2>/dev/null || hostname)

.PHONY: serve build drafts site check clean

## serve: the local preview, drafts included, on every interface at :1313
serve:
	@echo "preview: http://$(HOST):$(PORT)/"
	$(HUGO) server -D --disableFastRender \
		--bind $(BIND) --port $(PORT) \
		--baseURL "http://$(HOST):$(PORT)/" --appendPort=false

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
