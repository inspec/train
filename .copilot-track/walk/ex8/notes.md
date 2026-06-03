## ex8 security hygiene notes

Date: 2026-05-26

### Goal
Improve baseline secret-scanning hygiene with a dedicated CI scan and explicit handling of known-safe alerts.

### Baseline assessment
- Referred to `.github/workflows/ci-main-pull-request-stub.yml`.
- Existing pipeline enables TruffleHog via shared workflow inputs, but there was no focused repository-level secret-scan workflow file.

### Scanner added
- Added CI workflow: `.github/workflows/secret-scan.yml`
- Scanner: TruffleHog (Docker)
- Trigger model mirrors ci-main style:
  - pull_request to `main` and `release/**`
  - push to `main` and `release/**`
  - workflow_dispatch

### Local scan evidence
Baseline command:

```bash
docker run --rm -v "$PWD:/repo" trufflesecurity/trufflehog:latest filesystem /repo --json --no-update > .copilot-track/walk/ex8/trufflehog-baseline.json
```

Baseline summary:
- verified_secrets: 0
- unverified_secrets: 6
- Findings included:
  - `/repo/.git/packed-refs` SonarCloud detector false positives
  - `/repo/test/unit/transports/gcp_test.rb` fake token fixture used in tests

After remediation/ignore command:

```bash
docker run --rm -v "$PWD:/repo" trufflesecurity/trufflehog:latest filesystem /repo --json --no-update --exclude-paths=/repo/.trufflehogignore > .copilot-track/walk/ex8/trufflehog-after.json
```

After summary:
- verified_secrets: 0
- unverified_secrets: 0

### Remediation / justified ignore
Added `.trufflehogignore` with narrow path-based patterns:
- `^/repo/\.git/`
  - justification: VCS internals contain commit hashes that are not secrets.
- `^/repo/test/unit/transports/gcp_test\.rb$`
  - justification: test fixture includes intentionally fake credential-like strings.

### Security documentation update
- Updated `SECURITY.md` with:
  - CI secret-scan workflow reference
  - local verification command
  - rule to keep ignores narrow and justified

### Coverage/contract note
- This change touches CI/security process only, not runtime behavior.
- Existing unit/integration suite remains the behavioral contract guard.

### Rollback
- Revert ex8 commit(s) affecting:
  - `.github/workflows/secret-scan.yml`
  - `.trufflehogignore`
  - `SECURITY.md`
  - `.copilot-track/walk/ex8/*`
