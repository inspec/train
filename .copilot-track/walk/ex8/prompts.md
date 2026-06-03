## ex8 prompts

Date: 2026-05-26

### Primary exercise prompt
Goal / Outcome: Improve baseline security hygiene. Add a pre-commit or CI secret check and remediate 1-2 alerts.

Steps
- Evaluate current secret/security scanning in the repo. If none exists, recommend a lightweight tool.
- Add or configure the scanning step (pre-commit hook or CI job).
- Run the scan and remediate at least one finding, or add a documented justification for ignoring it.
- Update security notes or a SECURITY.md file with the new process.

Acceptance
- Scan step added or improved
- At least one security improvement or justified ignore
- Security notes updated

Troubleshooting
- If the scanner produces many false positives, configure exclusion rules for known-safe patterns and document them.
- If local installation is not possible, use a CI-only approach and provide pipeline config evidence.

Execution requirements
- Create a plan first: list steps and files to change.
- Then produce diffs file-by-file.
- Include: test strategy, evidence to capture (coverage/contract), and rollback.
- Keep scope small and reviewable.
- Avoid submodules/vendor folders.

### Follow-up prompt
- please refer to ci-main-pull-request file

### Scope captured in this run
- Added dedicated secret scan workflow using TruffleHog.
- Added narrowly scoped ignore rules with justification.
- Updated SECURITY.md with secret scan process and local verification command.
- Captured baseline and post-change scan evidence.

## Output

Date: 2026-05-26

### Result summary
- Added CI workflow: `.github/workflows/secret-scan.yml`
- Added scanner ignore file: `.trufflehogignore`
- Updated security documentation: `SECURITY.md`
- Added plan and notes artifacts under `.copilot-track/walk/ex8/`

### Baseline scan output
Command:

```bash
docker run --rm -v "$PWD:/repo" trufflesecurity/trufflehog:latest filesystem /repo --json --no-update > .copilot-track/walk/ex8/trufflehog-baseline.json
```

Observed summary:
- verified_secrets: 0
- unverified_secrets: 6

Notable findings:
- `/repo/.git/packed-refs` (hash-like false positives)
- `/repo/test/unit/transports/gcp_test.rb` (fake token fixture in tests)

### Post-remediation scan output
Command:

```bash
docker run --rm -v "$PWD:/repo" trufflesecurity/trufflehog:latest filesystem /repo --json --no-update --exclude-paths=/repo/.trufflehogignore > .copilot-track/walk/ex8/trufflehog-after.json
```

Observed summary:
- verified_secrets: 0
- unverified_secrets: 0

### Acceptance mapping
- Scan step added or improved: yes
- At least one security improvement or justified ignore: yes
- Security notes updated: yes

### Rollback
- Revert ex8 commit(s) affecting:
	- `.github/workflows/secret-scan.yml`
	- `.trufflehogignore`
	- `SECURITY.md`
	- `.copilot-track/walk/ex8/*`

