## Plan

Exercise: ex5

### Goal / Outcome
Reduce regression risk by adding boundary validation through a contract test for a stable output shape, and integrate that validation into CI if feasible.

### Chosen contract boundary
- Boundary: `Train::Transports::Helpers::Azure::FileCredentials.parse`
- Surface type: response shape contract (schema-like assertion on returned hash)
- Why this boundary:
  - It represents a clear data contract between config parsing and Azure transport setup.
  - Existing tests verify values and errors, but do not explicitly enforce response keys/type shape as a contract.

### Scope (small and reviewable)
Target 3-4 files:
- `test/unit/transports/helpers/azure/file_credentials_test.rb`
  - Add contract test asserting required keys, key set, and non-nil shape for valid inputs.
- `docs/contract-tests.md` (new)
  - Document how to run contract test and how to intentionally update contract when shape changes.
- `.copilot-track/walk/ex5/notes.md` (new)
  - Capture local run output for the contract test.
- Optional CI integration (if feasible):
  - `.github/workflows/contract-tests.yml` (new)
  - Run targeted contract test on PRs affecting contract files.

### Planned implementation sequence
1. Add a dedicated contract test case in `file_credentials_test.rb` for response shape.
2. Run targeted unit test locally and record pass/fail output.
3. If feasible, add lightweight CI workflow for contract test path.
4. Add documentation for running and updating contract tests.
5. Capture evidence in ex5 notes for PR inclusion.

### Contract test design
- Given a valid single-entry credentials file, `parse` must return a Hash with exactly:
  - `:subscription_id`
  - `:tenant_id`
  - `:client_id`
  - `:client_secret`
- Assert key set equality and value presence to guard accidental field drift.
- Keep the contract deterministic (no timestamps/random fields).

### Validation strategy
- Targeted run:
  - `bundle exec ruby -Ilib:test test/unit/transports/helpers/azure/file_credentials_test.rb`
- Broader safety run (optional if needed by touched files):
  - `bundle exec rake test`
- Lint changed files:
  - `chefstyle <changed files>`

### Evidence to capture
- Contract test command + output summary (runs/failures/errors/skips).
- Confirmation of contract key set.
- If CI workflow added: workflow file path and trigger conditions.
- Update instructions for intentional contract changes.

### Acceptance mapping
- At least one contract test added: new response-shape contract test in Azure helper test file.
- Contract test runs successfully: local command output captured in notes.
- Update instructions documented: `docs/contract-tests.md` includes update process.

### Troubleshooting path
- If no API boundary is suitable, continue with this data schema boundary (config parser output).
- If tests become noisy, assert only deterministic fields and exact key set.
- If CI integration is too heavy for scope, document local command and include evidence in PR instead.

### Risk and rollback
- Risk: low (test + docs, optional lightweight CI).
- Rollback: revert ex5 files only (contract test/docs/CI additions).
