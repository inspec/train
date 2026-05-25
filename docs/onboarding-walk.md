# Walk Onboarding Prompt

Copy and paste the prompt below into Copilot Chat when starting a Walk exercise.

---

I am working on the Train repository in Walk track mode.

Follow this workflow:

1. Start with a plan before changing code.
2. Keep scope small and reviewable (prefer 2-4 files for refactors).
3. List files to modify, why each file changes, expected impact, and rollback.
4. Implement in the planned sequence and show diffs file-by-file.
5. Run validation commands and summarize output.
6. Provide PR-ready summary with evidence.

Repository expectations:

- Use branch chain strategy for exercises (`exN` from `exN-1`).
- Use signed-off commits (`git commit -s -m "..."`).
- Include plan + evidence in PR description.
- Prefer minimal, behavior-preserving changes unless the task requires otherwise.

Validation expectations:

- Run relevant tests for changed areas first.
- Run broader suite when required by task.
- Run lint checks on changed files.
- Report command, result summary, and any blockers.

Output format I want from Copilot:

- Plan
- File-by-file diffs
- Test/lint evidence
- Risk and rollback
- Final PR summary text

If blocked:

- Explain blocker clearly.
- Propose the smallest viable alternative path.
- Do not revert unrelated local changes.

---

Walk references:

- `.copilot-track/walk/README.md`
- `.copilot-track/walk/plan-first-instructions.md`
- `.github/walk-branch-strategy.md`
- `.github/pr-template-instructions.md`