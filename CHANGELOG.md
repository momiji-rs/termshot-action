# Changelog

Notable changes to termshot screens are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
version numbers follow [Semantic Versioning](https://semver.org/). Pushing a tag
`vX.Y.Z` publishes the section of that version as the release notes.

## [Unreleased]

### Added

- A guide for Ink, docs/ink.md. It forces colour in Vitest, so the frames keep their escape
  sequences, and writes each frame from ink-testing-library with `toMatchFileSnapshot`. It also
  waits for `useInput` before pressing keys. Its example, examples/ink, runs in this
  repository's screens workflow.
- A guide for Ratatui, docs/ratatui.md. Beside each insta text snapshot, which shows no
  colour, it keeps an ANSI snapshot of what the terminal receives, written with Ratatui's own
  crossterm backend into memory, as insta's `.snap.ansi`. termshot-action renders those. Its
  example, examples/ratatui, runs in this repository's screens workflow.

## [0.5.0] - 2026-10-07

### Added

- A guide for Bubble Tea, docs/bubbletea.md, which turns teatest golden files into pull request
  screenshots. It covers the three settings that make a golden file the same on every machine,
  `WaitFor` consuming output, and the alternate screen. Its example, examples/bubbletea, runs
  in this repository's screens workflow.

### Changed

- The action uploads screens with `actions/upload-artifact` v7, which runs on Node 24; v4 ran
  on Node 20, which GitHub has deprecated, and each run warned about it. Self-hosted runners
  need [runner 2.327.1](https://github.com/actions/runner/releases/tag/v2.327.1) or newer;
  GitHub-hosted runners already have it. The artifacts are the same, so baselines and the
  comment workflow are unaffected.

### Fixed

- install-core.sh and install.sh check the download with sha256sum when the runner has no
  shasum, as on Arch Linux, and print the path when there is no GITHUB_OUTPUT.

## [0.4.0] - 2026-10-07

### Changed

- The action no longer runs Python. Its core is
  [gh-termshot](https://github.com/momiji-rs/gh-termshot) 0.2.0 (`core-version`), one static
  binary that the action downloads and checks against its release's SHA256SUMS. The same code
  makes gh-termshot's local previews.
- Rendering uses the termshot library built into the core, instead of downloading the termshot
  CLI. On the screens checked, the PNG, text and JSON are byte for byte the CLI's, so baselines
  stored by 0.3.x still match.
- `termshot-version` has no default now. Set it, or `termshot-path`, to render with a termshot
  CLI as before.
- `args` takes `--lf-newline` with the built-in renderer. Other termshot options need
  `termshot-version` or `termshot-path`.

### Added

- `core-version` and `core-path` choose the core.
- CI runs the action itself on Linux (x86-64 and arm64) and macOS. The core's own tests, ported
  from the Python suite, run in gh-termshot.

## [0.3.1] - 2026-10-07

### Fixed

- With `images: bundle`, the report and the baseline named the publish job's
  termshot, not the render job's that made the images. The render job now records
  its version in the bundle, and the publish job shows it, or `?` if it isn't a
  plain version string.

## [0.3.0] - 2026-10-07

### Added

- `images: bundle` for mode publish: use the PNG, text and JSON the render job made
  instead of rendering the logs again, for projects whose change is the rendering.
  They are checked as untrusted data (a PNG within size limits, a termshot `--json`
  screen of the shot's size) and taken only from runs of the repository's own
  branches.

### Changed

- The commands a shot runs, and termshot itself, get an environment without
  `INPUT_*`, `GITHUB_TOKEN`, `GH_TOKEN` and the runner's `ACTIONS_*` credentials.
  This is defence in depth: a job that runs code it doesn't trust should still hold
  no write token (mode render).

### Fixed

- Mode run no longer publishes for a commit that is no longer the pull request's
  head or the branch's, so an older run finishing last can't overwrite a newer
  run's comment or baseline. Mode publish already checked this.

## [0.2.2] - 2026-10-07

### Changed

- Releases are published by a workflow when a version tag is pushed: tests on Linux
  (x86-64 and arm64) and macOS, release notes from this file, and the major tag
  (`v0`) moved to the release. No change to the action itself.

## [0.2.1] - 2026-10-07

### Changed

- The README records that images in a private repository's comment show for
  signed-in viewers with access (verified on github.com). No change to the action.

## [0.2.0] - 2026-10-07

### Added

- `mode: render` captures and renders only, with no API calls, so the job that
  builds and runs your code needs no write permission: `permissions: {}` on a
  public repository, `contents: read` on a private one.
- `bundle-dir` publishes from a later job of the same run, for a one-file setup
  without forks.

### Changed

- `mode: publish` on `workflow_run` handles pushes (baselines) as well as pull
  requests, from forks or not. It needs `contents: write` and
  `pull-requests: write`, plus `actions: read` on a private repository.
- A publish run for a commit that is no longer the head is skipped, not failed.

## [0.1.0] - 2026-10-07

### Added

- Shots run in a real PTY, at a size per shot, and can be driven with steps:
  `wait`, `wait-for`, `type`, `key` and `snap`.
- One sticky comment per pull request: before and after, a cell diff image, and a
  text diff. Changes are detected exactly, because termshot is deterministic.
- Content-addressed storage on an orphan `termshot-assets` branch, pruned after
  `retention-days`.
- Pull requests from forks are published by a `workflow_run` workflow, which
  treats the artifact as untrusted data.

[Unreleased]: https://github.com/momiji-rs/termshot-action/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/momiji-rs/termshot-action/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/momiji-rs/termshot-action/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/momiji-rs/termshot-action/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/momiji-rs/termshot-action/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/momiji-rs/termshot-action/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/momiji-rs/termshot-action/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/momiji-rs/termshot-action/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/momiji-rs/termshot-action/releases/tag/v0.1.0
