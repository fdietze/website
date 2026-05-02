#!/usr/bin/env bash
set -euo pipefail

# Build wrapper for local use, Nix, and GitHub Actions.
#
# Zola does not emit our legacy post URLs as literal `.html` files.
# For pages with paths like `2021/08/29/post-name.html`, it generates a
# directory `post-name.html/` containing `index.html`. The live site at
# `https://felx.me` serves the non-slash form and returns 404 for the
# slash-suffixed variant, so we normalize the output after `zola build`.
zola build
"$(dirname "$0")/fix-html-paths.sh" public
