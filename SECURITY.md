# Security Policy

## Reporting a Vulnerability

See https://chef.io/security for our security policy and how to report a vulnerability.

## Secret Scanning

This repository runs a dedicated CI secret scan using TruffleHog via
`.github/workflows/secret-scan.yml`.

### CI behavior

- Runs on pull requests and pushes targeting `main` and `release/**`.
- Fails the workflow when potential secrets are detected.
- Uses `.trufflehogignore` for narrowly scoped, documented false-positive exclusions.

### Local verification

If TruffleHog is not installed locally, run it through Docker:

```bash
docker run --rm \
	-v "$PWD:/repo" \
	trufflesecurity/trufflehog:latest \
	filesystem /repo \
	--no-update \
	--exclude-paths=/repo/.trufflehogignore
```

Any new ignore entry must include a security justification and should be as specific as possible.
