# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A collection of standalone Bash utility scripts, one per directory, each with its own `README.md` documenting usage and arguments. There is no build system, test suite, or linter; scripts are run directly (e.g. `./token-exchange/token-exchange.sh ...`). When changing a script's arguments or behaviour, update its README in the same change.

## Scripts

- `client-credentials-grant/` — OAuth client credentials grant, authenticating with a signed client-assertion JWT. Supports RS256/RS384/RS512 via an optional 6th argument.
- `token-exchange/` — OAuth token exchange (RFC 8693) with a client-assertion JWT. Supports RS256/RS384/RS512 via an optional 7th argument. Takes 6 required positional args: subject token, client id, token url, private key, audience (for the client assertion) and target audience (for the exchanged token).
- `sqs-poller/` — Long-polls an AWS SQS queue via the AWS CLI, appends each message (body parsed as JSON when possible) to a JSON array file, and **deletes each message from the queue after saving it**.
- `docs/` — browser tools served by GitHub Pages from `main` `/docs` (https://janverhoeckx.github.io/utility-scripts/). `docs/oauth.html` is a single self-contained page (inline JS/CSS, no external resources, strict CSP) covering both OAuth scripts with WebCrypto signing; private keys and subject tokens are never persisted, only non-secret profiles in `localStorage`. See `docs/README.md`.
- `git-statistics/git-statistics` — Commit and tag counts over the last year for a list of repo paths. Uses BSD `date -v-1y`, so it only works on macOS as written.

## Shared patterns

- Both OAuth scripts build and sign the client-assertion JWT by hand (no JWT library): base64url via `openssl base64 | tr '+/' '-_' | tr -d '='`, signed with `openssl dgst -<digest> -sign <pem>`, claims `iss`/`sub` = client id, `aud`, a `uuidgen` `jti`, `iat` = now and `exp` = now + 60s (Keycloak rejects assertions without `iat` whose `exp` exceeds its max lifetime). The logic is duplicated in both scripts and in `docs/oauth.html`, so a fix in one usually needs porting to the other two. Keep the page's form fields and claims in parity with the scripts.
- Dependencies: `openssl`, `uuidgen`, `curl`, `jq`; the SQS poller also needs a configured `aws` CLI.

## Local-only files

`*/certs/` (private keys used for testing), `.idea` and `.DS_Store` are gitignored. Poller output files like `sqs-poller/*.json` are untracked local data and can contain real message contents, so don't commit them.
