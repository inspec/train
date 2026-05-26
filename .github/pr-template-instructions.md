# Walk PR Template Instructions

Use the following template for all Pull Requests in this repository.

**Title format:** `GHCP -- Walk: <ex#> <name>`

```
## Summary
- What changed and why
- Plan: <link to plan or inline summary>
- Files/paths touched

## Evidence
- Tests/logs/metrics: <commands + output summary>
- Coverage: <total percentage + exact command used>

## Risk & Rollback
- Risk: low/medium/high and why
- Rollback plan:
	- Primary: revert <commit SHA>
	- Alternate: disable/toggle <flag or workflow> if applicable
	- Impact/Recovery note: <what to expect after rollback>

## Review Focus
- Review focus (3-5 bullets):
	- <riskiest file/path>: what changed and why it matters
	- <logic branch or edge case>: what to verify
	- <config/docs/CI behavior>: what outcome should be visible
- Reviewer verification steps (copy/paste runnable):
	1. <command>
	2. <command>
	3. <expected result>
- Optional AI review request:
	- If repo settings support it, request AI/Copilot review and link any notable findings.

## Track
- Level: Walk
- Exercise: <ex#>
```
