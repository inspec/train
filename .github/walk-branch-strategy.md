# Walk Track — Branch Strategy

## Overview

Walk exercises form a **chain**: each exercise branches from the previous one,
keeping diffs focused and reviewable. PRs target the previous exercise's branch
(not `main`), so each PR shows only the incremental change for that exercise.

---

## Naming Convention

```
vasundhara-walk-ex1
vasundhara-walk-ex2
vasundhara-walk-ex3
...
```

Pattern: `vasundhara-walk-ex<N>`

---

## Branch Chain

```
main
 └── vasundhara-walk-ex1       ← branches from main
      └── vasundhara-walk-ex2  ← branches from ex1
           └── vasundhara-walk-ex3  ← branches from ex2
                ...
```

### Rules

| Exercise | Branch from | PR base |
|---|---|---|
| ex1 | `main` | `main` |
| ex2 | `vasundhara-walk-ex1` | `vasundhara-walk-ex1` |
| ex3 | `vasundhara-walk-ex2` | `vasundhara-walk-ex2` |
| exN | `vasundhara-walk-ex(N-1)` | `vasundhara-walk-ex(N-1)` |

---

## Creating a Branch

```bash
# ex1 — branch from main
git checkout main
git pull origin main
git checkout -b vasundhara-walk-ex1

# ex2 — branch from ex1
git checkout vasundhara-walk-ex1
git checkout -b vasundhara-walk-ex2

# exN — branch from ex(N-1)
git checkout vasundhara-walk-ex(N-1)
git checkout -b vasundhara-walk-exN
```

---

## Opening a PR

Always set `--base` to the **previous exercise branch**:

```bash
# ex1 PR — base is main
gh pr create \
  --base main \
  --head vasundhara-walk-ex1 \
  --title "GHCP -- Walk: ex1 <name>"

# ex2 PR — base is ex1
gh pr create \
  --base vasundhara-walk-ex1 \
  --head vasundhara-walk-ex2 \
  --title "GHCP -- Walk: ex2 <name>"
```

> This keeps each PR diff focused on only the changes introduced by that exercise.

---

## Why This Pattern?

- **Focused diffs** — reviewers see only what changed per exercise
- **Incremental history** — each exercise builds cleanly on the last
- **Easy rollback** — revert or close a single PR without affecting others
- **Audit trail** — prompt logs + branch chain create a full trace of AI-assisted work

---

## Quick Reference

| Resource | Path |
|---|---|
| This doc | `.github/walk-branch-strategy.md` |
| PR template | `.github/pr-template-instructions.md` |
| Walk README | `.copilot-track/walk/README.md` |
