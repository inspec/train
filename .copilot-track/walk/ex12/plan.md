## Plan

Exercise: ex12

### Goal / Outcome
Translate findings from prior exercises into structured future work by drafting an epic-style backlog document with actionable items, acceptance criteria, code-path links, and dependencies.

### Approach
- Use the repository fallback instead of issue tracker creation.
- Add a backlog document under `docs/` so it can be referenced from future PRs.
- Keep items small enough to fit in a single PR each.

### Steps
1. Review findings from recent exercises and extract 3-5 concrete follow-up opportunities.
2. Draft an epic-style backlog document containing:
   - scope and non-goals
   - 3-5 backlog items
   - acceptance criteria per item
   - code-path links per item
   - dependencies between items
3. Add ex12 notes capturing why the repo-document fallback was used and what evidence was collected.

### Files to change
- `docs/backlog.md` (new)
  - Epic-style future work document.
- `.copilot-track/walk/ex12/notes.md` (new)
  - Evidence, tracker fallback note, rollback guidance.

### Test strategy
- Documentation-only change.
- Validate consistency and completeness:
  - each backlog item has acceptance criteria
  - each backlog item links to code paths
  - dependencies are explicit

### Evidence to capture (coverage/contract)
- Document path for epic/backlog fallback.
- File diff proving 3-5 actionable items exist.
- Coverage/contract note: no runtime behavior changes.

### Rollback
- Revert commit touching:
  - `docs/backlog.md`
  - `.copilot-track/walk/ex12/*`

### Troubleshooting
- If any item feels too large, split it into smaller issue-sized bullets inside the backlog.
- If tracker access becomes available later, convert backlog items into issues while preserving code-path links and dependencies.
