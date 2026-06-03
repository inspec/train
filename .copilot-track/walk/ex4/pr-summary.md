## Summary
- Added Walk-track contributor guidance to make the plan-first, evidence-backed workflow explicit for this repository.
- Updated `CONTRIBUTING.md` with Walk-specific expectations: branch chaining, plan-first execution, evidence requirements, signed-off commits, and Copilot usage guardrails.
- Added a concise onboarding prompt at `docs/onboarding-walk.md` that new developers can paste into Copilot Chat to get oriented quickly.
- Linked both contribution resources from `README.md` so contributors can discover them from the primary project entry point.
- This work was completed with AI assistance following Progress AI policies.

## Plan
- Plan path: `.copilot-track/walk/ex4/plan.md`

## Files/paths touched
- `CONTRIBUTING.md`
- `docs/onboarding-walk.md`
- `README.md`
- `.copilot-track/walk/ex4/plan.md`

## Evidence
- Documentation scope remained constrained to 3 deliverable docs files plus the exercise plan file.
- README now links to both:
  - `CONTRIBUTING.md`
  - `docs/onboarding-walk.md`
- Walk workflow guidance now includes:
  - branch strategy
  - PR expectations
  - Copilot usage approach
  - plan/evidence expectations

## Risk & Rollback
- Risk: low (documentation-only changes; no runtime behavior changes).
- Rollback: revert commit `2d9c38b`.

## Review Focus
- Verify the Walk section in `CONTRIBUTING.md` is additive and does not conflict with existing external contribution guidance.
- Verify onboarding prompt in `docs/onboarding-walk.md` is concise enough for a single Copilot paste.
- Verify README links are correct and discoverable in the Contributing section.

## Track
- Level: Walk
- Exercise: ex4
