# Changelog

Notable changes to termshot screens are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
version numbers follow [Semantic Versioning](https://semver.org/). Pushing a tag
`vX.Y.Z` publishes the section of that version as the release notes.

## [Unreleased]

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

[Unreleased]: https://github.com/momiji-rs/termshot-action/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/momiji-rs/termshot-action/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/momiji-rs/termshot-action/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/momiji-rs/termshot-action/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/momiji-rs/termshot-action/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/momiji-rs/termshot-action/releases/tag/v0.1.0
