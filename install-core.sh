#!/usr/bin/env bash
# Puts the action's core, a gh-termshot release binary, in the runner's tool
# cache, checked against the release's SHA256SUMS, and prints its path as
# bin=<path> to $GITHUB_OUTPUT. VERSION picks the release; LOCAL skips the
# download (core-path).
set -euo pipefail
# sha256sum where there is one (Linux), shasum otherwise (macOS).
check() { if command -v sha256sum >/dev/null; then sha256sum -c -; else shasum -a 256 -c -; fi; }
# bin=<path> to $GITHUB_OUTPUT in a workflow, or to stdout.
emit() { if [ -n "${GITHUB_OUTPUT:-}" ]; then echo "$1" >> "$GITHUB_OUTPUT"; else echo "$1"; fi; }
if [ -n "${LOCAL:-}" ]; then
  emit "bin=$(cd "$(dirname "$LOCAL")" && pwd)/$(basename "$LOCAL")"
  exit 0
fi
case "$RUNNER_OS-$RUNNER_ARCH" in
  Linux-X64) platform=linux-amd64 ;;
  Linux-ARM64) platform=linux-arm64 ;;
  macOS-ARM64) platform=darwin-arm64 ;;
  macOS-X64) platform=darwin-amd64 ;;
  *) echo "::error::termshot-action has no build for $RUNNER_OS $RUNNER_ARCH"; exit 1 ;;
esac
dir="${RUNNER_TOOL_CACHE:-$HOME/.cache}/gh-termshot/${VERSION:?}"
name="gh-termshot-$platform"
if [ ! -x "$dir/$name" ]; then
  url="https://github.com/momiji-rs/gh-termshot/releases/download/v$VERSION"
  tmp=$(mktemp -d)
  curl -fsSL --retry 3 -o "$tmp/$name" "$url/$name"
  curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "$url/SHA256SUMS"
  (cd "$tmp" && grep " $name\$" SHA256SUMS | check)
  mkdir -p "$dir"
  chmod +x "$tmp/$name"
  mv "$tmp/$name" "$dir/$name"
fi
emit "bin=$dir/$name"
