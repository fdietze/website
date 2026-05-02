#!/usr/bin/env bash
set -euo pipefail

# Convert Zola's directory-style output for `.html` paths into literal files.
#
# Example:
#   public/2021/08/29/post.html/index.html
# becomes:
#   public/2021/08/29/post.html
#
# This is required to preserve the existing live URLs on `felx.me`, where
# `/.../post.html` returns 200 but `/.../post.html/` returns 404.
output_dir="${1:-public}"

while IFS= read -r html_dir; do
  parent_dir="$(dirname "$html_dir")"
  html_name="$(basename "$html_dir")"
  temp_dir="${html_dir}.tmp"

  mv "$html_dir" "$temp_dir"
  mv "$temp_dir/index.html" "$parent_dir/$html_name"
  rmdir "$temp_dir"
done < <(find "$output_dir" -depth -type d -name '*.html' | sort)
