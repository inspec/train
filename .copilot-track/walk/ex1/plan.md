## Plan

### What changes and why
Add a small architecture map that ties a few conceptual Train components to real repo paths, show at least one dependency flow and one data flow, and add a validation step so the diagram is rendered in CI. This strengthens architectural understanding while keeping the scope reviewable.

### Files touched
- `docs/architecture.md` - human-readable overview and links from concepts to source paths.
- `docs/architecture.mmd` - Mermaid source for the architecture diagram.
- `contrib/validate_architecture_diagram.sh` - local validation script that renders the diagram.
- `.github/workflows/architecture-diagram-validate.yml` - CI job that runs the validation script.

### Sequence of edits
1. Create the Mermaid diagram with 3-5 key nodes mapped to real file paths.
2. Add 2-3 flows, including at least one dependency flow and one data flow.
3. Add the validation script so the diagram can be rendered locally.
4. Add the CI workflow so the render check runs on pull requests.
5. Run the validation script and capture the output as evidence.

### Test strategy
- Validate Mermaid syntax by rendering `docs/architecture.mmd` through the local script.
- Validate the CI path by running the workflow job that installs Mermaid CLI and renders the same source file.
- Keep the check focused on diagram compilation only; no Ruby runtime behavior changes are expected.

### Evidence I will collect
- Test command: `contrib/validate_architecture_diagram.sh`
- Validation result: Mermaid render completes without errors
- CI evidence: workflow job output showing the diagram render check passed
- Optional artifact: rendered `docs/architecture.svg` if the renderer writes one

### Risk and rollback
- Risk: low. The change is documentation and validation only; it does not alter runtime Ruby code.
- Rollback: revert the four files listed above, or remove the new Walk exercise directory if the change is abandoned before merge.
