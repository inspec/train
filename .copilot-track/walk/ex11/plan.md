## Plan

Exercise: ex11

### Goal / Outcome
Improve PR review clarity and efficiency by standardizing review focus bullets, reviewer verification steps, and rollback details in Walk PR guidance.

### Implementation approach
- Prefer documentation/template updates (no runtime code changes).
- Keep scope small and reviewable by updating existing Walk PR template instructions and Walk README guidance.

### Steps
1. Update `.github/pr-template-instructions.md` to require:
   - 3-5 review focus bullets with rationale.
   - explicit verification steps reviewers can run locally.
   - clear rollback plan in PR text.
2. Update `.copilot-track/walk/README.md` PR body template section to mirror the new structure.
3. Add an optional AI review request note in PR guidance (non-blocking, depends on repo capabilities).
4. Validate docs formatting and capture evidence in notes.

### Files to change
- `.github/pr-template-instructions.md`
- `.copilot-track/walk/README.md`
- `.copilot-track/walk/ex11/notes.md` (new)

### Test strategy
- Documentation-only change:
  - verify template structure renders and is internally consistent.
  - no runtime/unit test changes required.

### Evidence to capture (coverage/contract)
- File diffs showing required PR sections and bullet/step structure.
- Example verification command placeholders retained for reviewer use.
- Coverage/contract note: no product behavior changes.

### Rollback
- Revert commit touching the documentation/template files above.

### Troubleshooting
- If reviewers report template too verbose, keep section headers but shorten bullet text while preserving 3-5 focus items and explicit verification steps.
