## Summary
- Improved Walk PR guidance to make reviews faster and clearer.
- Standardized PR template expectations for review focus bullets, reviewer verification steps, and rollback detail.
- Kept the change doc-only and limited to Walk process artifacts.

## Plan
- Plan artifact: `.copilot-track/walk/ex11/plan.md`
- Scope: update PR guidance docs only, no runtime code changes.

## Files Touched
- `.github/pr-template-instructions.md`
- `.copilot-track/walk/README.md`
- `.copilot-track/walk/ex11/plan.md`

## Evidence
- Validation type: documentation/template consistency check.
- Verified both template locations now require:
  - Review focus (3-5 bullets)
  - Copy/paste reviewer verification steps
  - Clear rollback plan with primary/alternate/recovery notes
  - Optional AI/Copilot review request guidance
- Coverage/contract note: no runtime behavior changes.

## Risk & Rollback
- Risk: low (docs-only process guidance).
- Rollback plan:
  - Primary: revert commit `6e766ea`
  - Alternate: revert just docs if partial rollback needed:
    - `.github/pr-template-instructions.md`
    - `.copilot-track/walk/README.md`
  - Impact/Recovery note: rollback restores previous PR template wording with no product impact.

## Review Focus
- `.github/pr-template-instructions.md`: confirm new Review Focus and Risk/Rollback structure is explicit and actionable.
- `.copilot-track/walk/README.md`: confirm PR Body Template mirrors the same structure for consistency.
- `.copilot-track/walk/ex11/plan.md`: confirm plan-first traceability and scope alignment.

## Reviewer Verification Steps
1. Open `.github/pr-template-instructions.md` and verify `## Review Focus` includes 3-5 bullets + runnable verification steps.
2. Open `.copilot-track/walk/README.md` and verify PR Body Template matches the same sections and expectations.
3. Confirm no runtime files under `lib/` or `test/` were modified in this commit.

## Track
- Level: Walk
- Exercise: ex11
