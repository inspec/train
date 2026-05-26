# 🚶 Walk Track — Copilot Development Guide

The Walk track builds on the Crawl track. Exercises here require more context
awareness, multi-file reasoning, and structured output habits.

---

## Key Differences from Crawl

| Dimension | Crawl | Walk |
|---|---|---|
| Scope | Single file / single task | Multi-file, cross-cutting changes |
| PR granularity | One commit, one PR | PR chain — one PR per exercise |
| Evidence required | Optional | **Mandatory** evidence section in every PR |
| Prompt logging | Informal | Log prompts per exercise in `prompts.md` |
| Branch naming | freestyle | `<username>-walk-ex<N>` |
| Review focus | Correctness | Correctness + reasoning transparency |

---

## Branch & PR Chain Standards

### Branch Naming
```
vasundhara-walk-ex<N>
```
Example: `vasundhara-walk-ex1`, `vasundhara-walk-ex2`

### PR Chain Pattern
Each exercise branches from the **previous exercise's branch** (not `main`).
This keeps each PR diff focused on only the incremental change for that exercise.

```
main
 └── vasundhara-walk-ex1       ← branches from main, PR base = main
      └── vasundhara-walk-ex2  ← branches from ex1, PR base = ex1
           └── vasundhara-walk-ex3  ← branches from ex2, PR base = ex2
```

> Full branch strategy: `.github/walk-branch-strategy.md`

### Commit Message Format
```
GHCP Walk ex<N>: <short description>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

Create commits with sign-off enabled:
```bash
git commit -s -m "GHCP Walk ex<N>: <short description>"
```

---

## Opening a PR — Step-by-Step

1. **Finish all changes** on your exercise branch.
2. **Run tests and linting**:
   ```bash
   bundle install
   bundle exec rake test
   chefstyle && chefstyle -a
   ```
3. **Commit** everything (including any lint fixes).
   ```bash
   git add .
   git commit -s -m "GHCP Walk ex<N>: <short description>"
   ```
4. **Push** the branch:
   ```bash
   git push origin <username>-walk-ex<N>
   ```
5. **Create the PR** using the template below:
   ```bash
   gh pr create \
     --title "GHCP -- Walk: ex<N> <name>" \
     --body "$(cat .github/pr-template-instructions.md)" \
     --label "runtest:all:stable" \
     --label "ai-assisted"
   ```
6. **Verify labels** are applied: `runtest:all:stable` and `ai-assisted`.

---

## PR Body Template

> Full template lives at: `.github/pr-template-instructions.md`

```markdown
## Summary
- What changed and why
- Plan: <link to plan or inline summary>
- Files/paths touched

## Evidence
- Tests/logs/metrics: <commands + output summary>
- Coverage: <percentage or contract evidence>

## Risk & Rollback
- Risk: low / medium / high and why
- Rollback plan:
   - Primary: revert <commit SHA>
   - Alternate: disable/toggle <flag or workflow> if applicable
   - Impact/Recovery note

## Review Focus
- Review focus (3-5 bullets):
   - Riskiest file/logic and why
   - Edge cases to inspect
   - CI/config/doc behavior that should be visible
- Reviewer verification steps (copy/paste runnable):
   1. <command>
   2. <command>
   3. <expected result>
- Optional AI review request:
   - If available in repo settings, request AI/Copilot review and include notable findings.

## Track
- Level: Walk
- Exercise: <ex#>
```

---

## Evidence Section — Required in Every PR

Every Walk PR **must** include an Evidence section. Minimum requirements:

| Item | What to include |
|---|---|
| Test command | The exact command run, e.g. `bundle exec rake test` |
| Test result | Pass/fail summary, e.g. `47 runs, 0 failures, 0 errors` |
| Coverage | Percentage from SimpleCov or equivalent |
| Lint | Output of `chefstyle` — must be clean before merge |

Example:
```
## Evidence
- Tests: `bundle exec rake test` → 47 runs, 0 failures, 0 errors, 0 skips
- Coverage: 84% (SimpleCov)
- Lint: `chefstyle` → no offenses detected
```

---

## Log Prompts per Exercise

For every exercise, maintain a prompt log at:
```
.copilot-track/walk/ex<N>/prompts.md
```

### Format
```markdown
# ex<N> Prompt Log

## Prompt 1
**Input:** <what you asked Copilot>
**Output summary:** <brief description of what Copilot produced>
**Used as-is / modified / discarded:** <choice>

## Prompt 2
...
```

This log is required for Walk exercises to build the habit of intentional,
auditable AI-assisted development.

---

## Quick Reference Paths

| Resource | Path |
|---|---|
| This README | `.copilot-track/walk/README.md` |
| PR template | `.github/pr-template-instructions.md` |
| Copilot instructions | `.github/copilot-instructions.md` |
| Exercise prompt logs | `.copilot-track/walk/ex<N>/prompts.md` |
| Unit tests | `test/unit/` |
| Integration tests | `test/integration/` |
| Lib source | `lib/train/` |
