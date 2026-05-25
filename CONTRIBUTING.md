# Contributing to a Progress Chef InSpec Project
Thank you for your interest in contributing to this project! It is part of the larger Progress Chef InSpec project. Contribution guidelines can be found at [Contributing to Progress Chef InSpec](https://chef.github.io/chef-oss-practices/projects/inspec/contributing/).

## Walk Track Workflow

Use this section when contributing via the Walk methodology.

### Branching Strategy

- Branches are chained by exercise:
	- `vasundhara-walk-ex1` branches from `main`
	- `vasundhara-walk-ex2` branches from `vasundhara-walk-ex1`
	- `vasundhara-walk-exN` branches from `vasundhara-walk-ex(N-1)`
- Open each PR against the previous exercise branch to keep diffs focused.

### Plan-First Requirement

- Create a written plan before implementation.
- Keep scope small and reviewable (prefer 2-4 files for refactors).
- Include: files to change, sequence of edits, validation strategy, evidence, and rollback.

### Evidence Requirements

- Every PR must include a clear Evidence section.
- Provide exact commands and summarized outputs for tests/lint.
- When applicable, include coverage percentage or explicit contract evidence.

### Commits and PR Expectations

- Use signed-off commits:
	- `git commit -s -m "..."`
- Keep commits focused on one exercise outcome.
- Use the Walk PR template and include:
	- plan reference
	- files touched
	- validation output
	- risk and rollback

### Copilot Usage in Walk Track

- Ask Copilot to produce a plan first, then implement in sequence.
- Review diffs file-by-file before accepting.
- If tests fail, diagnose and fix before reverting.
- If scope expands beyond the intended size, reduce to the smallest meaningful subset.

For full Walk references, see:

- `.copilot-track/walk/README.md`
- `.copilot-track/walk/plan-first-instructions.md`
- `.github/walk-branch-strategy.md`
- `.github/pr-template-instructions.md`