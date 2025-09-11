---
title: "GitHub Copilot Instructions for Train Repository"
version: "1.1.0"
last_reviewed: "2025-09-11"
maintainers: "Train Core Maintainers (@chef/inspec-core)"
applies_to: "train, train-core (dual gemspec packaging)"
supported_ruby: ">= 3.1"
minimum_coverage_goal: "80%"
style_tool: "ChefStyle"
test_framework: "Minitest + Mocha"
ci_coverage_env: "CI_ENABLE_COVERAGE=1"
---

# GitHub Copilot Instructions for Train Repository

## TL;DR (Contributor Fast Checklist)
1. bundle install
2. Run tests: bundle exec rake test
3. Lint: bundle exec chefstyle ; bundle exec chefstyle -a ; fix leftovers
4. Add/Update code + unit tests (>80% coverage)
5. Add comprehensive documentation (YARD + README + docs/)
6. Commit with JIRA ID: JIRA-12345: concise summary
7. Create branch (JIRA ID), push, open PR with label runtest:all:stable
8. Respond to review, keep commits atomic

## Change Type → Required Actions Matrix
Change Type | Actions
------------|--------
Small bugfix (logic) | Add failing unit test → fix → lint → PR
New transport | Create lib/train/transports/<name>.rb + tests + YARD docs + README update + docs/<name>_transport.md + usage examples + troubleshooting guide
Enhance existing transport | Update code + targeted tests (success/failure) + adjust platform logic/tests
Plugin (non-transport) utility | Add under lib/train/plugins/... + tests + docs
Dependency bump (runtime) | Update gemspec/Gemfile + run bundle update <gem> + verify compatibility matrix
Security fix | Add regression test, document in PR, consider CHANGELOG entry
Refactor (no behavior change) | Ensure unchanged public API; rely on existing tests + add tests for uncovered branches
Performance improvement | Add micro-benchmark (optional) + ensure no behavior regression
Documentation only | Spellcheck + ensure examples run (if code)

## What NOT To Do
- Do NOT edit generated / vendored content (none presently ending in *.codegen.go, still verify).
- Do NOT add external runtime deps casually—prefer stdlib or existing deps; justify additions.
- Do NOT introduce global state without thread-safety review.
- Do NOT change transport option names without deprecation path.
- Do NOT rescue Exception broadly—target specific Train error classes.
- Do NOT add large binary fixtures (compress/synthesize/mocks instead).

## Repository Overview

This repository contains the Train Transport Interface, a Ruby library that provides a unified interface to talk to local or remote operating systems and APIs. Train is a core component of the Chef InSpec ecosystem.

### Folder Structure
```
train/
├── .github/                              # GitHub workflows and configurations
│   ├── CODEOWNERS                        # Code ownership definitions
│   ├── ISSUE_TEMPLATE/                   # Issue templates
│   ├── dependabot.yml                    # Dependabot configuration
│   ├── lock.yml                          # Lock configuration
│   └── workflows/                        # CI/CD workflows
├── .expeditor/                           # Chef Expeditor CI configuration
├── contrib/                              # Contribution utilities
├── docs/                                 # Documentation
├── examples/                             # Example code and plugins
├── lib/                                  # Core Train library code
│   ├── train/                            # Main Train modules
│   │   ├── extras/                       # Additional utilities
│   │   ├── file/                         # File handling modules
│   │   ├── platforms/                    # Platform detection
│   │   ├── plugins/                      # Plugin system
│   │   └── transports/                   # Transport implementations
│   │       ├── clients/                  # Transport clients
│   │       └── helpers/                  # Transport helpers
│   └── train.rb                          # Main entry point
├── test/                                 # Test suites
│   ├── fixtures/                         # Test fixtures and plugins
│   ├── integration/                      # Integration tests
│   ├── unit/                             # Unit tests (Minitest)
│   └── windows/                          # Windows-specific tests
├── Gemfile                               # Ruby dependencies
├── Rakefile                              # Rake tasks
├── train.gemspec                         # Gem specification
├── train-core.gemspec                    # Core gem specification
└── README.md                             # Project documentation
```

### Key Technologies
- **Ruby**: Primary language (Ruby >= 3.1)
- **Minitest**: Primary testing framework
- **SimpleCov**: Code coverage tool (enabled only when CI_ENABLE_COVERAGE=1)
- **Bundler**: Ruby dependency management
- **Rake**: Ruby build tool
- **Mocha**: Mocking framework
- **ChefStyle**: Ruby code style enforcement and linting

### Supported Transports
- Local execution
- SSH
- WinRM
- Docker and Podman
- Mock (for testing)
- AWS API
- Azure API
- VMware via PowerCLI
- Habitat

## Critical Instructions

### 🚨 File Modification Restrictions
- **DO NOT modify any `*.codegen.go` files** if present in the repository
- These are auto-generated files and should never be manually edited
- Always check for presence of codegen files before making changes

### JIRA Integration & Task Implementation Workflow

When a JIRA ID is provided, follow this complete workflow:

#### 1. JIRA Issue Analysis
- Use the `atlassian-mcp-server` MCP server to fetch JIRA issue details
- Read and understand the story requirements thoroughly
- Identify all acceptance criteria and technical requirements
- Note any dependencies or constraints mentioned
- Consider transport-specific requirements and compatibility

#### 2. Implementation Planning
- Break down the task into smaller, manageable components
- Identify which files need to be created, modified, or tested
- Plan the implementation approach based on Train's architecture
- Consider existing transport patterns and plugin conventions
- Review platform compatibility requirements

#### 3. Code Implementation
- Implement the feature according to JIRA requirements
- Follow existing code patterns and Ruby conventions
- Ensure proper error handling and logging
- Add appropriate documentation and comments
- Consider cross-platform compatibility (Unix, Windows, etc.)
- Follow Train's plugin architecture when applicable

#### 4. Unit Test Creation & Validation
- **MANDATORY**: Create comprehensive unit test cases for all new code
- Use Minitest framework (primary testing framework in this repo)
- Ensure test coverage is **> 80%** for the repository
- Follow existing test patterns in `test/unit/` directories
- Mock external dependencies appropriately using Mocha
- Test both success and failure scenarios
- Include platform-specific tests when applicable
- Test transport-specific functionality thoroughly
- Run all unit tests to ensure they pass and verify coverage meets threshold
- Fix any failing tests or coverage issues

#### 5. Documentation Creation
- **MANDATORY**: Create comprehensive documentation for all new features (see Documentation Requirements section below for details)
- Follow all documentation standards and requirements outlined in this guide
- Ensure documentation is complete before proceeding to code quality checks

#### 6. Code Quality & Linting
- **MANDATORY**: Run ChefStyle linting before creating PR
- Execute `chefstyle` to check for style and formatting issues
- Run `chefstyle -a` to automatically fix correctable violations
- Review and manually fix any remaining ChefStyle violations that cannot be auto-corrected
- Ensure all code passes linting standards and style guidelines
- Verify no new linting violations are introduced
- Run any additional code quality tools if configured

#### 7. Pull Request Creation
- Use GitHub CLI to create a branch named after the JIRA ID
- Push changes to the new branch
- Create a PR with proper description using HTML tags
- **MANDATORY**: Add label `runtest:all:stable` to the PR
- PR description should include:
  - Summary of changes made
  - JIRA ticket reference
  - Testing performed
  - Platform compatibility notes
  - Any breaking changes or migration notes

### GitHub CLI Authentication & PR Workflow

```bash
# Authenticate with GitHub CLI
gh auth login

# Create feature branch (use JIRA ID as branch name)
git checkout -b JIRA-12345

# Make your changes, commit them
git add .
git commit -m "JIRA-12345: Brief description of changes"

# Run linting and fix issues before pushing
chefstyle

# Auto-fix correctable style violations
chefstyle -a

# Fix any remaining issues that ChefStyle couldn't auto-correct
# Review ChefStyle output and manually fix remaining violations

# Commit any linting fixes
git add .
git commit -m "JIRA-12345: Fix linting issues"

# Push branch
git push origin JIRA-12345

# Create PR with proper labeling
gh pr create \
  --title "JIRA-12345: Feature title" \
  --body "<h2>Summary</h2><p>Description of changes...</p><h2>JIRA</h2><p>JIRA-12345</p><h2>Testing</h2><p>Test coverage and validation performed...</p>" \
  --label "runtest:all:stable"
```

### Step-by-Step Workflow Example

When implementing a task, follow this prompt-based approach:

1. **Initial Analysis**
   - Fetch JIRA details using MCP server
   - Analyze requirements and create implementation plan
   - Consider Train-specific architecture and patterns
   - **Prompt**: "Analysis complete. Next step: Implementation planning. Ready to proceed? (y/n)"

2. **Implementation**
   - Create/modify necessary files
   - Follow coding standards and Train patterns
   - Implement transport-specific functionality if needed
   - **Prompt**: "Implementation complete. Next step: Unit test creation. Ready to proceed? (y/n)"

3. **Testing & Validation**
   - Create comprehensive unit tests
   - Run tests and verify coverage > 80%
   - Test platform compatibility when applicable
   - **Prompt**: "Tests created and passing. Coverage verified > 80%. Next step: Documentation creation. Ready to proceed? (y/n)"

4. **Documentation Creation**
   - Create comprehensive documentation for new features
   - Add inline YARD documentation for public methods
   - Update README.md and relevant docs/ files
   - Include usage examples and troubleshooting guides
   - **Prompt**: "Documentation completed and reviewed. Next step: Code quality & linting. Ready to proceed? (y/n)"

5. **Code Quality & Linting**
   - Run ChefStyle linting: `chefstyle` and `chefstyle -a`
   - Manually fix any remaining linting violations
   - Ensure all code passes style and quality standards
   - **Prompt**: "Code linting completed and all issues resolved. Next step: PR creation. Ready to proceed? (y/n)"

6. **PR Creation**
   - Create branch, commit changes, and create PR
   - Add required labels
   - **Prompt**: "PR created successfully. Workflow complete. Any additional steps needed? (y/n)"

### Testing Standards

#### Unit Testing Requirements
- **Framework**: Minitest (primary testing framework)
- **Coverage**: Maintain > 80% test coverage
- **Location**: Tests should be in `test/unit/` directories
- **Naming**: Test files should end with `_test.rb`
- **Mocking**: Use `mocha/minitest` for mocking external dependencies

#### Coverage Configuration
```ruby
# Example SimpleCov configuration
SimpleCov.start do
  add_filter "/test/"
  add_group "Transports", ["lib/train/transports"]
  add_group "Platforms", ["lib/train/platforms"]
  add_group "Plugins", ["lib/train/plugins"]
  minimum_coverage 80
end
```

#### Test Structure Example
```ruby
require "helper"

describe Train::Transports::MyTransport do
  let(:transport) { Train::Transports::MyTransport.new }
  
  describe "#connection" do
    it "establishes connection successfully" do
      conn = transport.connection
      _(conn).wont_be_nil
    end
    
    it "handles connection errors gracefully" do
      # Mock error conditions
      assert_raises(Train::TransportError) do
        transport.connection(invalid: true)
      end
    end
  end
end
```

### Code Quality Standards

#### Ruby Standards
- Follow Ruby community conventions
- Use proper indentation (2 spaces)
- Add appropriate comments and documentation
- Handle errors gracefully using Train's error classes
- Use meaningful variable and method names
- Follow Train's existing patterns for transports and plugins

#### Code Linting and Style Requirements
- **MANDATORY**: Run ChefStyle before submitting PR: `chefstyle`
- Auto-fix all possible style and formatting issues: `chefstyle -a`
- Manually resolve remaining ChefStyle violations that cannot be auto-corrected
- Follow Chef community Ruby style guidelines
- Ensure consistent code formatting across all files
- Address any security or performance warnings from linters

#### Transport Development Guidelines
- Inherit from `Train::Plugins::Transport`
- Implement required methods: `connection`, `options`
- Use Train's connection management patterns
- Handle platform-specific requirements
- Provide appropriate error handling
- Support Train's audit logging when applicable

#### Documentation Requirements
- **MANDATORY**: Add comprehensive documentation for all new features
- Add YARD documentation for public methods and classes using proper syntax
- Document transport-specific options, configuration, and usage examples
- Update README.md if adding user-facing features or new transports
- Create or update relevant documentation in `docs/` directory for major features
- Include clear usage examples and code samples that are tested and functional
- Document platform compatibility and requirements
- Add troubleshooting guides for common issues and error scenarios
- Document security considerations and best practices
- Add inline comments for complex logic and algorithms
- Document any breaking changes or migration requirements
- Ensure all documentation is clear, accurate, and follows project standards

### MCP Server Integration

The repository uses the `atlassian-mcp-server` for JIRA integration:

```json
{
  "servers": {
    "atlassian-mcp-server": {
      "url": "https://mcp.atlassian.com/v1/sse",
      "type": "http"
    }
  }
}
```

Use MCP server functions to:
- Fetch JIRA issue details
- Get issue requirements and acceptance criteria
- Understand context and dependencies
- Review transport-specific requirements

### Prompt-Based Interaction Guidelines

- After each major step, provide a summary of what was completed
- Clearly state what the next step will be
- List remaining steps in the workflow
- Ask for explicit confirmation before proceeding
- Allow for course correction if needed
- Consider platform and transport implications at each step

### Train-Specific Development Guidelines

#### Transport Development
- Follow the plugin architecture pattern
- Use Train's connection management
- Implement proper platform detection
- Handle authentication securely
- Support Train's file and command interfaces
- Provide meaningful error messages

#### Platform Support
- Consider cross-platform compatibility
- Test on multiple operating systems when applicable
- Use Train's platform detection system
- Handle platform-specific edge cases

#### Plugin Development
- Follow Train's plugin registration system
- Provide proper plugin metadata
- Use semantic versioning
- Include comprehensive tests

### Additional Best Practices

1. **Version Control**
   - Make atomic commits with clear messages
   - Include JIRA ID in commit messages
   - Keep commits focused on single features

2. **Code Reviews**
   - Ensure PR descriptions are comprehensive
   - Include testing information in PR
   - Reference JIRA tickets appropriately
   - Document transport-specific changes

3. **Dependencies**
   - Update Gemfile when adding new Ruby gems
   - Run `bundle install` after dependency changes
   - Ensure all dependencies are properly locked
   - Consider gem compatibility with supported Ruby versions

4. **Performance**
   - Consider performance implications of transport changes
   - Test connection establishment and teardown
   - Optimize for common use cases
   - Profile transport performance when applicable

### Error Handling

- Always implement proper error handling using Train's error classes
- Use appropriate error types: `Train::TransportError`, `Train::UserError`
- Log errors appropriately for debugging
- Provide meaningful error messages to users
- Handle transport-specific error conditions

### Security Considerations

- Never commit sensitive information (credentials, keys)
- Use environment variables for configuration
- Follow security best practices for transport development
- Validate all inputs appropriately
- Handle authentication securely
- Consider security implications of new transports

---

## Workflow Summary

1. **JIRA Analysis** → Fetch and understand requirements (transport-specific)
2. **Planning** → Break down implementation approach (consider Train architecture)
3. **Implementation** → Code the solution following Train patterns
4. **Testing & Validation** → Create comprehensive tests (>80% coverage, run and verify)
5. **Documentation** → Create comprehensive documentation and usage examples
6. **Code Quality** → Run ChefStyle linting and fix all issues
7. **PR Creation** → Use GitHub CLI with proper labeling

Remember: All tasks should be prompt-based with explicit confirmation at each step, maintaining high code quality and test coverage standards throughout the process. Consider Train's transport architecture and cross-platform compatibility in all development work.
