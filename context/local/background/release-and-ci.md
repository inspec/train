---
repo: inspec/train
products:
  - inspec
  - chef-infra-client
divisions:
  - chef
---

# Release, Versioning & CI (Train repo)

Authoritative notes on how the `train` repo actually builds, versions, tests, and
ships — sourced from `.expeditor/` and the gemspecs. This supersedes any
JIRA/prompt-style workflow text under `context/local/standards/workflow.md`, which
is illustrative, not the house process.

## Release automation — Chef Expeditor

Releases are driven by **Chef Expeditor** (`.expeditor/config.yml`), not by manual
tagging or `gem push`. The relevant machinery:

- **Published gems:** `train` and `train-core` (`rubygems:` in the config).
- **On every PR merged to a release branch**, Expeditor runs, in order:
  1. `built_in:bump_version` (skippable with the `Expeditor: Skip Version Bump` /
     `Expeditor: Skip All` labels),
  2. `bash:.expeditor/update_version.sh` (only if the version bumped),
  3. `built_in:update_changelog`,
  4. `built_in:build_gem`,
  5. trigger the `coverage` pipeline.
- **On promotion** (`project_promoted`): `built_in:rollover_changelog` then
  `built_in:publish_rubygems`.
- **Git tags:** `v{{version}}` format; PR branches are deleted on merge.
- **Release branches:** `main` (version constraint `3.*`) and `2-stable` (`2.*`).

### Versioning (SemVer, label-driven)

- The version lives in `lib/train/version.rb` (`Train::VERSION`, currently
  **3.16.5**) and is bumped automatically.
- Default bump is a patch. Apply a PR label to bump higher:
  - `Expeditor: Bump Minor Version`
  - `Expeditor: Bump Major Version`
- Don't hand-edit `version.rb` in a feature PR; let Expeditor own it.

## Continuous integration — Buildkite

PRs are validated by the **`verify`** Buildkite pipeline
(`.expeditor/verify.pipeline.yml`; 20-min timeout, one automatic retry):

- **Lint** — `RAKE_TASK=lint` runs **ChefStyle** on the oldest supported Ruby
  (**3.1**), to catch new Ruby-isms early.
- **Tests** — the Minitest suite runs on **Ruby 3.1** and **Ruby 3.4** (Linux),
  plus **Ruby 3.1 on Windows**.
- A separate **`coverage`** pipeline (`.expeditor/coverage.pipeline.yml`) generates
  the coverage report; coverage is **not** a merge gate (see
  [../standards/testing.md](../standards/testing.md)).

## Supported Ruby

- **Authoritative floor:** `required_ruby_version >= 3.1.0` in both
  `train.gemspec` and `train-core.gemspec`.
- CI exercises **3.1** (floor) and **3.4**. A local `.ruby-version` file, if
  present, is untracked/gitignored and is **not** the supported-version pin.

## Gem layout (what ships where)

- **`train-core`** — the plugin system + a minimal in-repo backend set
  (`local`, `ssh`, `cisco_ios`, `mock`); light dependencies. Does **not** bundle
  winrm.
- **`train`** — the "batteries included" meta-gem: `train-core` **plus** the
  external **`train-winrm`** gem (`~> 0.4.0`) and the heavier in-repo cloud/container
  transports (`azure`, `gcp`, `docker`, `podman`, `vmware`) with their SDKs.
- External transports (`winrm`, `aws`, `rest`, `kubernetes`, …) ship as separate
  `train-*` plugin gems. See the canonical
  [in-repo vs external transport map](../../shared/by-product/train/design/architecture.md#in-repo-transports-vs-external-plugin-gems)
  and [../../shared/by-product/train/advice/plugin-packaging.md](../../shared/by-product/train/advice/plugin-packaging.md).

## What this means for a contributor

- Open a PR against `main`; keep it green on the `verify` pipeline (ChefStyle +
  tests on 3.1/3.4).
- Do **not** bump the version or edit the changelog by hand — add the appropriate
  `Expeditor: Bump …` label if a non-patch release is warranted.
- The gem is published automatically on promotion; there is no manual `gem push`
  step.
