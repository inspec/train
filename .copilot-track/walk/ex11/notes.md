## ex11 review clarity notes

Date: 2026-05-26

### Goal
Improve review clarity and efficiency by standardizing PR review focus bullets, verification steps, and rollback details.

### What changed
- Updated `.github/pr-template-instructions.md` to require:
  - 3-5 review focus bullets with explicit rationale.
  - reviewer verification steps in copy/paste command format.
  - clear rollback plan with primary, alternate, and impact/recovery notes.
  - optional AI/Copilot review request guidance.
- Updated `.copilot-track/walk/README.md` PR body template section to match the same structure.

### Acceptance mapping
- Review focus section included: yes
- Verification steps documented: yes
- Clear rollback plan included: yes

### Test strategy
- Documentation-only change.
- Verified updated template sections render and remain consistent across both docs.

### Evidence to capture (coverage/contract)
- File diffs showing required PR section changes.
- Coverage/contract note: no runtime behavior change; process/documentation only.

### Rollback
- Revert commit touching:
  - `.github/pr-template-instructions.md`
  - `.copilot-track/walk/README.md`
  - `.copilot-track/walk/ex11/*`
