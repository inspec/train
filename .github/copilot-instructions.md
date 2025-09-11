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

---
title: "GitHub Copilot Instructions for Train Repository"
version: "2.0.0"
last_reviewed: "2025-09-11"
maintainers: "Train Core Maintainers (@chef/inspec-core)"
---

# GitHub Copilot Instructions for Train Repository

## Repository Overview

This repository contains the Train Transport Interface, a Ruby library that provides a unified interface to talk to local or remote operating systems and APIs. Train is a core component of the Chef InSpec ecosystem.

## Folder Structure
```
train/
├── .github/                              # GitHub workflows and configurations
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

## Critical Instructions

### 🚨 File Modification Restrictions
- **DO NOT modify any `*.codegen.go` files** if present in the repository
- These are auto-generated files and should never be manually edited
- Always check for presence of codegen files before making changes

## JIRA Integration & MCP Server Usage

When a JIRA ID is provided:
- Use the `atlassian-mcp-server` MCP server to fetch JIRA issue details
- Read and understand the story requirements thoroughly
- Identify all acceptance criteria and technical requirements
- Implement the task according to the story requirements

## Testing Requirements

- **MANDATORY**: Create comprehensive unit test cases for all implementations
- Ensure test coverage is **> 80%** for the repository
- Use Minitest framework (primary testing framework in this repo)
- Follow existing test patterns in `test/unit/` directories
- Mock external dependencies appropriately

## GitHub CLI & PR Creation

When prompted to create a PR:
- Use GitHub CLI to create a branch named after the JIRA ID
- Push changes to the new branch
- Create a PR with proper description using HTML tags
- **MANDATORY**: Add label `runtest:all:stable` to the PR
- All tasks will be performed on local repo

### GitHub CLI Commands
```bash
# Authenticate with GitHub CLI (no ~/.profile needed)
gh auth login

# Create feature branch (use JIRA ID as branch name)
git checkout -b JIRA-12345

# Make your changes, commit them
git add .
git commit -m "JIRA-12345: Brief description of changes"

# Push branch
git push origin JIRA-12345

# Create PR with proper labeling
gh pr create \
  --title "JIRA-12345: Feature title" \
  --body "<h2>Summary</h2><p>Description of changes...</p><h2>JIRA</h2><p>JIRA-12345</p>" \
  --label "runtest:all:stable"
```

## Prompt-Based Workflow

All tasks should be prompt-based with the following approach:
- After each step, provide a summary of what was completed
- Clearly state what the next step will be
- List remaining steps in the workflow
- Ask for explicit confirmation before proceeding: "Ready to proceed? (y/n)"
- Allow for course correction if needed

## Complete Implementation Workflow

When implementing a task, follow this step-by-step workflow:

### Step 1: JIRA Analysis
- Fetch JIRA details using atlassian-mcp-server
- Analyze requirements and acceptance criteria
- Create implementation plan
- **Prompt**: "Analysis complete. Next step: Implementation. Ready to proceed? (y/n)"

### Step 2: Implementation
- Create/modify necessary files (avoiding prohibited files)
- Follow existing code patterns and conventions
- Ensure proper error handling
- **Prompt**: "Implementation complete. Next step: Unit test creation. Ready to proceed? (y/n)"

### Step 3: Unit Test Creation
- Create comprehensive test cases for all new code
- Ensure test coverage > 80%
- Run tests to verify they pass
- **Prompt**: "Tests created and passing. Coverage verified > 80%. Next step: Documentation. Ready to proceed? (y/n)"

### Step 4: Documentation
- Add appropriate code documentation
- Update README if needed
- Create/update relevant documentation files
- **Prompt**: "Documentation complete. Next step: PR creation. Ready to proceed? (y/n)"

### Step 5: PR Creation
- Create branch using JIRA ID as branch name
- Commit and push changes
- Create PR with HTML-formatted description
- Add required label "runtest:all:stable"
- **Prompt**: "PR created successfully. Workflow complete. Any additional steps needed? (y/n)"

## MCP Server Configuration

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

## Key Technologies
- **Ruby**: Primary language (Ruby >= 3.1)
- **Minitest**: Primary testing framework
- **SimpleCov**: Code coverage tool
- **Bundler**: Ruby dependency management
- **ChefStyle**: Ruby code style enforcement

## Best Practices
- Follow existing code patterns in the repository
- Use meaningful variable and method names
- Handle errors gracefully using Train's error classes
- Write clear, concise code with appropriate comments
- Ensure cross-platform compatibility when applicable

Remember: All tasks should be prompt-based with explicit confirmation at each step, maintaining high code quality and test coverage standards throughout the process.
