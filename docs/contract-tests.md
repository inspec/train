# Contract Tests

This repository uses contract tests to validate boundary behavior that should not change unintentionally.

## Current Contract Surface

- Azure credentials parser response shape:
  - `Train::Transports::Helpers::Azure::FileCredentials.parse`
  - Test file: `test/unit/transports/helpers/azure/file_credentials_test.rb`

## Run Contract Tests Locally

Prerequisite:

```bash
bundle install
```

Run the contract-focused test:

```bash
bundle exec ruby -Ilib:test test/unit/transports/helpers/azure/file_credentials_test.rb
```

## Contract Definition

For a valid credentials file, `parse` must return a Hash with exactly these keys:

- `:subscription_id`
- `:tenant_id`
- `:client_id`
- `:client_secret`

All keys above must map to non-nil values.

## Updating the Contract Intentionally

If the boundary changes intentionally:

1. Update parser implementation and contract test assertions together.
2. Update this document's "Contract Definition" section.
3. Include rationale in PR summary and state how downstream callers are affected.
4. Re-run contract tests and include output in PR Evidence.
