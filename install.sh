#!/usr/bin/env bash
# Puts a termshot release in the runner's tool cache and prints its path as
# bin=<path> to $GITHUB_OUTPUT. VERSION picks the release; LOCAL skips the download.
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
  Linux-X64) platform=linux-x86_64-musl ;;
  Linux-ARM64) platform=linux-aarch64-musl ;;
  macOS-*) platform=macos-universal ;;
  *) echo "::error::termshot has no build for $RUNNER_OS $RUNNER_ARCH"; exit 1 ;;
esac
dir="${RUNNER_TOOL_CACHE:-$HOME/.cache}/termshot/${VERSION:?}/$platform"
if [ ! -x "$dir/termshot" ]; then
  name="termshot-$VERSION-$platform"
  url="https://github.com/momiji-rs/termshot/releases/download/v$VERSION"
  tmp=$(mktemp -d)
  curl -fsSL --retry 3 -o "$tmp/$name.tar.gz" "$url/$name.tar.gz"
  curl -fsSL --retry 3 -o "$tmp/SHA256SUMS" "$url/SHA256SUMS"
  (cd "$tmp" && grep " $name.tar.gz\$" SHA256SUMS | check)
  mkdir -p "$dir"
  tar -xzf "$tmp/$name.tar.gz" -C "$dir" --strip-components 1
fi
emit "bin=$dir/termshot"
