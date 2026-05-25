## Plan

Exercise: ex4

### Goal / Outcome
Clarify how contributors should use the Walk methodology by adding Walk-specific contribution guidance, a paste-ready onboarding prompt, and README links to both.

### Current state and gap
- `CONTRIBUTING.md` currently points to external Chef InSpec contribution guidelines and does not describe Walk-specific practices.
- `README.md` has a generic Contributing section but no link to Walk onboarding guidance.

### Scope (small and reviewable)
Target 3 files:
- `CONTRIBUTING.md`
- `docs/onboarding-walk.md`
- `README.md`

### Planned changes
1. Update `CONTRIBUTING.md` with a focused "Walk Track" section (do not rewrite the full file), covering:
   - branch chain strategy (`exN` from `exN-1`)
   - plan-first workflow
   - evidence expectations (tests, coverage/contract evidence)
   - signed-off commit requirement
   - PR expectations and labels for this repo
2. Create `docs/onboarding-walk.md` as a concise one-page prompt a new developer can paste into Copilot Chat, including:
   - repository context
   - workflow checklist
   - expected outputs (plan, diffs, evidence)
   - pitfalls and guardrails
3. Add links in `README.md` under contributing docs to:
   - `CONTRIBUTING.md`
   - `docs/onboarding-walk.md`

### File-by-file diff workflow
- Apply edits one file at a time.
- Review each file diff immediately after edit.
- Avoid unrelated formatting or broad content rewrites.

### Validation strategy
- Check markdown formatting and readability for all three files.
- Ensure links resolve to existing paths.
- Optional lint check if markdown lint tooling is available.

### Evidence to capture for PR
- Plan path: `.copilot-track/walk/ex4/plan.md`
- Diff summary for the 3 modified files
- Confirmation that README links point to the new/updated docs
- Brief note that onboarding prompt fits in a single paste

### Acceptance mapping
- CONTRIBUTING updated or created: update existing `CONTRIBUTING.md` with Walk-specific section.
- Walk workflow clearly described: covered in both `CONTRIBUTING.md` and `docs/onboarding-walk.md`.
- Documentation linked in PR: include links in README and PR body.

### Troubleshooting path
- If `CONTRIBUTING.md` is already thorough, append only a Walk section and keep external link intact.
- If onboarding prompt grows too large, trim to one page and move extra details to references.
- If changes begin touching more than 3-4 files, reduce scope back to the three files listed above.

### Risk and rollback
- Risk: low (documentation-only changes).
- Rollback: revert the ex4 docs commit affecting `CONTRIBUTING.md`, `docs/onboarding-walk.md`, and `README.md`.
