# Copyright 2026 The OpenTacit Authors
# SPDX-License-Identifier: Apache-2.0

HUGO ?= hugo
TACIT ?= ../tacit

.PHONY: serve build drafts tokens check clean

## serve: the local preview, drafts included, at http://localhost:1313
serve:
	$(HUGO) server -D --disableFastRender

## build: what CI publishes — no drafts, minified, real base URL
build:
	$(HUGO) --minify --baseURL "https://blog.opentacit.com/"

## drafts: build including drafts, for looking at one before it goes out
drafts:
	$(HUGO) -D --minify

## tokens: re-copy the palette out of the registry's stylesheet
tokens:
	./hack/sync-tokens.sh $(TACIT)

## check: fail if the palette here has drifted from app.css next door
check:
	./hack/sync-tokens.sh --check $(TACIT)

clean:
	rm -rf public resources
