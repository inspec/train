# GitHub Copilot Instructions for Train Repository

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
- **Ruby**: Primary language (Ruby 2.7+)
- **Minitest**: Primary testing framework
- **SimpleCov**: Code coverage tool
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
git commit -s -m "JIRA-12345: Brief description of changes"

# Run linting and fix issues before pushing
chefstyle

# Auto-fix correctable style violations
chefstyle -a

# Fix any remaining issues that ChefStyle couldn't auto-correct
# Review ChefStyle output and manually fix remaining violations

# Commit any linting fixes
git add .
git commit -s -m "JIRA-12345: Fix linting issues"

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
   - **Prompt**: "Tests created and passing. Coverage verified > 80%. Next step: Code quality & linting. Ready to proceed? (y/n)"

4. **Code Quality & Linting**
   - Run ChefStyle linting: `chefstyle` and `chefstyle -a`
   - Manually fix any remaining linting violations
   - Ensure all code passes style and quality standards
   - **Prompt**: "Code linting completed and all issues resolved. Next step: PR creation. Ready to proceed? (y/n)"

5. **PR Creation**
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
- Add YARD documentation for public methods
- Include examples in documentation
- Document transport-specific options and requirements
- Update README files when necessary
- Document platform compatibility
- Provide usage examples in `docs/` directory
- Include clear usage examples and code samples that are tested and functional
- Add troubleshooting guides for common issues and error scenarios

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
5. **Code Quality** → Run ChefStyle linting and fix all issues
6. **PR Creation** → Use GitHub CLI with proper labeling
6. **Prompt-based** → Confirm each step before proceeding

Remember: All tasks should be prompt-based with explicit confirmation at each step, maintaining high code quality and test coverage standards throughout the process. Consider Train's transport architecture and cross-platform compatibility in all development work.

1. AI-Assisted Development & Compliance
✅ Create PR with ai-assisted label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description
2. Jira Ticket Updates (MANDATORY)
✅ IMMEDIATELY after PR creation: Update Jira ticket custom field customfield_11170 ("Does this Work Include AI Assisted Code?") to "Yes"
✅ Use atlassian-mcp tools to update the Jira field programmatically
✅ CRITICAL: Use correct field format: {"customfield_11170": {"value": "Yes"}}
✅ Verify the field update was successful
3. Documentation Requirements
✅ Reference AI assistance in commit messages where appropriate
✅ Document any AI-generated code patterns or approaches in PR description
✅ Maintain transparency about which parts were AI-assisted vs manual implementation
Workflow Integration
This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes" 
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
Never skip Jira field updates - This is required for Progress AI governance
Always verify updates succeeded - Check response from atlassian-mcp tools
Treat as atomic operation - PR creation and Jira updates should happen together
Double-check before final summary - Confirm all AI compliance items are completed
Audit Trail
All AI-assisted work must be traceable through:

GitHub PR labels (ai-assisted)
Jira custom field (customfield_11170 = "Yes")
PR descriptions mentioning AI assistance
Commit messages where relevant

---

## Walk Track — Branch Strategy

See [`.github/walk-branch-strategy.md`](.github/walk-branch-strategy.md) for the full Walk branch and PR chain strategy.

**Summary:**
- `ex1` branches from `main`
- `ex2` branches from `ex1`, `ex3` from `ex2`, and so on
- PR base = previous exercise branch (keeps diffs focused)
- Branch naming: `vasundhara-walk-ex<N>`
- Use signed-off commits: `git commit -s -m "..."`

---

## PR Template

See [`.github/pr-template-instructions.md`](.github/pr-template-instructions.md) for the Walk PR template.