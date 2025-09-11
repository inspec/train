---
Title: GitHub Copilot Instructions for Train Repository
Version: 1.1.0
Last Reviewed: 2025-09-11
Maintainers: Train Core Maintainers (@chef/inspec-core)
Applies-To: tr#### 6. Code Quality & Linting
- **MANDATORY**: Run ChefStyle linting before creating PR
- Execute `chefstyle` to check for style and formatting issues
- Run `chefstyle -a` to automatically fix correctable violations
- Review and manually fix any remaining ChefStyle violations that cannot be auto-corrected
- Ensure all code passes linting standards and style guidelines
- Verify no new linting violations are introduced
- Run any additional code quality tools if configured

#### 7. Documentation Creation & Validation
- **MANDATORY**: Create or update documentation before PR creation
- Add YARD documentation for all new public methods and classes
- Update README.md if adding user-facing features or transports
- Create detailed documentation files in `docs/` directory for new transports or major features
- Include usage examples, configuration options, and troubleshooting guides
- Document platform compatibility and requirements
- Validate all code examples in documentation actually work
- Update any relevant existing documentation that may be affected by changes
- Ensure documentation follows Train's documentation standards and style

#### 8. Pull Request Creation-core (dual gemspec packaging)
Supported-Ruby: ">= 3.1" (CI matrix authoritative)
Minimum-Coverage-Goal: 80%
Style-Tool: ChefStyle
Test-Framework: Minitest + Mocha
CI-Coverage-Env: CI_ENABLE_COVERAGE=1
---

# GitHub Copilot Instructions for Train Repository

## TL;DR (Contributor Fast Checklist)
1. bundle install
2. Run tests: bundle exec rake test (or bundle exec rake for default task)
3. (If measuring locally) CI_ENABLE_COVERAGE=1 bundle exec rake test
4. Lint: bundle exec chefstyle ; bundle exec chefstyle -a ; fix leftovers
5. Add/Update code + unit tests (always) in test/unit
6. Add fixtures only if absolutely required (prefer mocks over new fixtures)
7. For transports / plugins: follow plugin skeleton below & add unit tests + integration tests (if realistic)
8. Update CHANGELOG via Expeditor commands in commit body if needed (or rely on automation)
9. Commit with JIRA ID: JIRA-12345: concise summary
10. Create branch (JIRA ID), push, open PR with label runtest:all:stable
11. Confirm >80% coverage on CI (SimpleCov only runs when CI_ENABLE_COVERAGE=1)
12. Respond to review, keep commits atomic

## Change Type → Required Actions Matrix
Change Type | Actions
------------|--------
Small bugfix (logic) | Add failing unit test → fix → lint → PR
New transport | Create lib/train/transports/<name>.rb + tests + option docs + update README if user-facing + add usage examples + troubleshooting guide
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

#### 4. Unit Test Creation
- **MANDATORY**: Create comprehensive unit test cases for all new code
- Use Minitest framework (primary testing framework in this repo)
- Ensure test coverage is **> 80%** for the repository
- Follow existing test patterns in `test/unit/` directories
- Mock external dependencies appropriately using Mocha
- Test both success and failure scenarios
- Include platform-specific tests when applicable
- Test transport-specific functionality thoroughly

#### 5. Test Execution & Validation
- Run all unit tests to ensure they pass
- Verify test coverage meets the 80% threshold
- Fix any failing tests or coverage issues
- Ensure no existing tests are broken by changes
- Run integration tests when applicable
- Test on multiple platforms if transport changes are involved

#### 6. Documentation Creation
- **MANDATORY**: Create comprehensive documentation for all new features
- Add inline code documentation using YARD format for public methods and classes
- Document transport-specific options, configuration, and usage examples
- Update README.md if adding user-facing features or new transports
- Create or update relevant documentation in `docs/` directory
- Include usage examples and code samples where applicable
- Document platform compatibility and requirements
- Add troubleshooting guide for common issues
- Ensure all documentation is clear, accurate, and follows project standards

#### 7. Code Quality & Linting
- **MANDATORY**: Run ChefStyle linting before creating PR
- Execute `chefstyle` to check for style and formatting issues
- Run `chefstyle -a` to automatically fix correctable violations
- Review and manually fix any remaining ChefStyle violations that cannot be auto-corrected
- Ensure all code passes linting standards and style guidelines
- Verify no new linting violations are introduced
- Run any additional code quality tools if configured

#### 8. Pull Request Creation
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

3. **Testing**
   - Create comprehensive unit tests
   - Run tests and verify coverage
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

#### Common ChefStyle Issues and Solutions
- **Line Length**: Break long lines (max 120 characters typically)
- **Method Length**: Extract complex logic into smaller methods
- **Class Length**: Consider splitting large classes into smaller components
- **Complexity**: Simplify complex conditional statements and loops
- **Documentation**: Add method and class documentation where required
- **Naming**: Use descriptive variable and method names following Ruby conventions
- **Indentation**: Ensure consistent 2-space indentation throughout

#### Transport Development Guidelines
- Inherit from `Train::Plugins::Transport`
- Implement required methods: `connection`, `options`
- Use Train's connection management patterns
- Handle platform-specific requirements
- Provide appropriate error handling
- Support Train's audit logging when applicable

#### Documentation Requirements
- **MANDATORY**: Add comprehensive documentation for all new features
- Add YARD documentation for public methods and classes
- Include clear usage examples and configuration options
- Document transport-specific requirements and platform compatibility
- Update README files when necessary for user-facing features
- Create troubleshooting guides for common issues
- Document security considerations and best practices
- Ensure all code examples are tested and functional
- Add inline comments for complex logic and algorithms
- Document any breaking changes or migration requirements

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
4. **Testing** → Create comprehensive tests (>80% coverage, platform compatibility)
5. **Documentation** → Create comprehensive documentation and usage examples
6. **Code Quality** → Run ChefStyle linting and fix all issues
7. **PR Creation** → Use GitHub CLI with proper labeling
8. **Prompt-based** → Confirm each step before proceeding

Remember: All tasks should be prompt-based with explicit confirmation at each step, maintaining high code quality and test coverage standards throughout the process. Consider Train's transport architecture and cross-platform compatibility in all development work.
