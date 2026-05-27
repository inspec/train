## ex12 backlog drafting notes

Date: 2026-05-27

### Goal
Turn findings from prior exercises into structured future work with actionable backlog items, acceptance criteria, code-path links, and dependencies.

### Tracker fallback used
- Used a committed repository document instead of issue tracker creation.
- Backlog path: `docs/backlog.md`
- Reason: repository-local fallback satisfies the exercise requirement without assuming Jira/GitHub issue creation access.

### Evidence captured
- Created 5 actionable backlog items.
- Each item includes:
  - problem statement
  - relevant code paths
  - acceptance criteria
  - dependency notes
  - suggested PR sizing

### Coverage/contract note
- Documentation-only change.
- No runtime or CI behavior changed.

### Rollback
- Revert commit touching:
  - `docs/backlog.md`
  - `.copilot-track/walk/ex12/*`
