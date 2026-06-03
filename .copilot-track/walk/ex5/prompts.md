# ex5 Prompt Log

## Prompt 1
**Input:** Create plan for ex5 focused on boundary validation and contract tests.
**Output summary:** Created `.copilot-track/walk/ex5/plan.md` with a concrete contract boundary (`FileCredentials.parse`), scoped file plan, validation strategy, CI feasibility, evidence expectations, and rollback.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 2
**Input:** Execute the plan.
**Output summary:** Added response-shape contract test in `test/unit/transports/helpers/azure/file_credentials_test.rb`, created `docs/contract-tests.md`, added CI workflow `.github/workflows/contract-tests.yml`, ran local contract test + lint, and captured evidence in `.copilot-track/walk/ex5/notes.md`.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 3
**Input:** Stage only ex5 deliverable files.
**Output summary:** Staged only deliverables (`file_credentials_test.rb`, `docs/contract-tests.md`, `.github/workflows/contract-tests.yml`) and left plan/notes unstaged.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 4
**Input:** Save prompts.
**Output summary:** Created this prompt log at `.copilot-track/walk/ex5/prompts.md`.
**Used as-is / modified / discarded:** Used as-is.
