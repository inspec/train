# ex2 Prompt Log

## Prompt 1
**Input:** Rename ex0 to ex2 and create plan for ex2 focused on coverage visibility.
**Output summary:** Renamed exercise folder to `.copilot-track/walk/ex2` and created `plan.md` with goals, files, sequence, test strategy, evidence, acceptance, troubleshooting, and rollback.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 2
**Input:** Execute the ex2 plan.
**Output summary:** Identified coverage setup (`Minitest` + `SimpleCov` via `CI_ENABLE_COVERAGE` in `test/helper.rb`), attempted coverage run, hit dependency resolution issue, and proceeded with dependency install.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 3
**Input:** Run bundle install.
**Output summary:** Ran `bundle install` successfully, resolving missing dependencies including `activesupport 7.2.3.1`.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 4
**Input:** Re-run coverage command.
**Output summary:** Executed `CI_ENABLE_COVERAGE=1 bundle exec rake test`; captured passing test summary and coverage result: `83.66% (2130 / 2546)`.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 5
**Input:** Bundle install is a prerequisite before running bundle exec command.
**Output summary:** Updated docs to make `bundle install` explicit before `bundle exec` commands in coverage/testing instructions.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 6
**Input:** Save the prompts.
**Output summary:** Created this prompt log at `.copilot-track/walk/ex2/prompts.md`.
**Used as-is / modified / discarded:** Used as-is.

## Prompt 7
**Input:** Write PR summary and store the output of the prompt in prompt file.
**Output summary:** Drafted a PR-ready summary in `.copilot-track/walk/ex2/pr-summary.md` with summary, evidence, coverage percentage, risk/rollback, and track details; logged this prompt and output in this file.
**Used as-is / modified / discarded:** Used as-is.
