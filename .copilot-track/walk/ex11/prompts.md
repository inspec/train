## ex11 prompts

Date: 2026-05-26

### Primary prompt
Goal / Outcome: Improve review clarity and efficiency. Auto-request AI review or define review focus bullets and verification steps.

Steps
- Before opening the PR, write 3-5 review focus bullets that tell the reviewer exactly what to look at and why.
- Add verification steps the reviewer can run locally to confirm the change works as intended.
- Include a clear rollback plan in the PR description.
- Generate the final PR text using the Walk PR template, then review and adjust before submitting.

Acceptance
- Review focus section included
- Verification steps documented
- Clear rollback plan included

Troubleshooting
- If unsure what to highlight, focus on the riskiest file or most complex logic.
- If PR is too large, split into smaller PRs and reference from parent issue.

Plan-first requirement
- List steps and files first.
- Produce file-by-file diffs.
- Include test strategy, evidence, and rollback.
- Keep scope small; avoid submodules/vendor folders.

### Output summary
- Updated Walk PR template instructions to require stronger Review Focus and Rollback sections.
- Updated Walk README PR template snippet to match.
- Added ex11 plan and notes artifacts.
