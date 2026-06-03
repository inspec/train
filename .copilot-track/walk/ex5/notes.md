# ex5 Contract Test Notes

## Contract boundary
- `Train::Transports::Helpers::Azure::FileCredentials.parse`
- Contract type: response shape assertion (schema-like key set + non-nil values)

## Local validation commands
```bash
bundle exec ruby -Ilib:test test/unit/transports/helpers/azure/file_credentials_test.rb
chefstyle test/unit/transports/helpers/azure/file_credentials_test.rb
```

## Local validation results
- Contract test: `10 runs, 30 assertions, 0 failures, 0 errors, 0 skips`
- Lint: `1 file inspected, no offenses detected`

## CI integration
- Added workflow: `.github/workflows/contract-tests.yml`
- Triggered on changes to:
  - `lib/train/transports/helpers/azure/file_credentials.rb`
  - `test/unit/transports/helpers/azure/file_credentials_test.rb`
  - `docs/contract-tests.md`
  - `.github/workflows/contract-tests.yml`

## Contract update instructions
- See `docs/contract-tests.md` section "Updating the Contract Intentionally" for update process.
