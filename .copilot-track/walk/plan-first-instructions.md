# Walk Track — Plan-First Instructions

## Core Principle

**No code without a plan.** Every Walk exercise begins with a written plan
before any implementation starts.

---

## Goals

- **Design and execute multi-file changes safely**
  Identify all affected files upfront. Sequence edits to avoid breakage.
  Never discover scope mid-implementation.

- **Write a plan before coding**
  Produce a written plan artifact for every exercise before touching any file.
  The plan lives in the PR body or as a linked doc.

- **Surface coverage or contract evidence**
  Every PR must show measurable evidence: test command + output, coverage %,
  or explicit behavioural contracts. "It works" is not evidence.

- **Maintain doc-with-code discipline**
  Documentation changes land in the **same PR** as the code they describe.
  Never split docs and code across separate PRs.

- **Deliver review-ready PRs with risk awareness**
  Every PR states a risk level (low / medium / high) and provides a concrete,
  actionable rollback step.

---

## Plan Format

Before writing any code, produce a plan with at minimum:

```markdown
## Plan

### What changes and why
<one paragraph describing the goal>

### Files touched
- `path/to/file.rb` — reason
- `path/to/test_file.rb` — reason

### Sequence of edits
1. <first change>
2. <second change>
3. ...

### Evidence I will collect
- Test command: `bundle exec rake test`
- Coverage target: >80%
- Lint: `chefstyle`
```

---

## Per-Exercise Checklist

- [ ] Plan written before any code was touched
- [ ] All affected files identified in the plan
- [ ] Edits made in the planned sequence
- [ ] Tests written or updated alongside code
- [ ] Evidence section in PR: test output + coverage %
- [ ] Docs updated in the same PR if public behaviour changed
- [ ] Risk level stated; rollback step is actionable
- [ ] `chefstyle` passes with no offenses
- [ ] Prompt log updated at `.copilot-track/walk/ex<N>/prompts.md`

---

## Quick Reference

| Resource | Path |
|---|---|
| This doc | `.copilot-track/walk/plan-first-instructions.md` |
| Walk README | `.copilot-track/walk/README.md` |
| Branch strategy | `.github/walk-branch-strategy.md` |
| PR template | `.github/pr-template-instructions.md` |
| Prompt logs | `.copilot-track/walk/ex<N>/prompts.md` |
