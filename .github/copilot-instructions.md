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
- **DO NOT modify auto-generated files** if present in the repository
- These files should never be manually edited
- Always check for presence of auto-generated files before making changes

### 🔒 Developer Certificate of Origin (DCO) Requirements
- **MANDATORY**: All commits must be signed with DCO using the `-s` flag
- Use `git commit -s` for all commits to add the required "Signed-off-by" line
- DCO ensures legal compliance and contribution authenticity
- Failing to sign commits will cause CI/CD pipeline failures
- If you forget to sign a commit, you can amend it: `git commit --amend -s`

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

## Testing Standards

### Unit Testing Requirements
- **Framework**: Minitest (primary testing framework)
- **Coverage**: Maintain > 80% test coverage for new code
- **Location**: Tests should be in `test/unit/transports/` for transport tests
- **Naming**: Test files should end with `_test.rb`
- **Mocking**: Use `mocha/minitest` for mocking external dependencies

### Transport Testing Patterns

```ruby
require "test_helper"

describe Train::Transports::YourTransport do
  let(:transport) { Train::Transports::YourTransport.new }
  let(:connection_options) { { host: 'example.com', port: 443 } }
  
  describe "transport registration" do
    it "registers the transport" do
      _(Train.create('your_transport')).must_be_instance_of Train::Transports::YourTransport
    end
  end
  
  describe "option validation" do
    it "requires host option" do
      _(proc { transport.connection({}) }).must_raise Train::UserError
    end
    
    it "uses default port when not specified" do
      conn = transport.connection(host: 'example.com')
      _(conn.options[:port]).must_equal 443
    end
  end
  
  describe "connection management" do
    it "creates new connection" do
      conn = transport.connection(connection_options)
      _(conn).must_be_instance_of Train::Transports::YourTransport::Connection
    end
    
    it "reuses existing connection when possible" do
      conn1 = transport.connection(connection_options)
      conn2 = transport.connection(connection_options)
      _(conn1).must_equal conn2
    end
  end
end

describe Train::Transports::YourTransport::Connection do
  let(:connection) { Train::Transports::YourTransport::Connection.new(connection_options) }
  let(:connection_options) { { host: 'example.com', port: 443 } }
  
  describe "platform detection" do
    it "detects correct platform" do
      platform = connection.platform
      _(platform.name).must_equal 'your_platform'
      _(platform.family_hierarchy).must_include 'api'
    end
  end
  
  describe "command execution" do
    it "executes commands successfully" do
      connection.stubs(:execute_command).returns(mock_result(stdout: 'output', stderr: '', exit_code: 0))
      result = connection.run_command('test command')
      _(result.stdout).must_equal 'output'
      _(result.exit_code).must_equal 0
    end
    
    it "handles command errors" do
      connection.stubs(:execute_command).raises(StandardError.new('Connection failed'))
      result = connection.run_command('failing command')
      _(result.exit_code).must_equal 1
      _(result.stderr).must_include 'Connection failed'
    end
  end
  
  describe "file operations" do
    it "handles file access" do
      connection.stubs(:get_file_info).returns(mock_file_info)
      file = connection.file('/path/to/file')
      _(file).must_be_instance_of Train::File::Remote
    end
    
    it "handles missing files" do
      connection.stubs(:get_file_info).raises(FileNotFoundError)
      file = connection.file('/nonexistent')
      _(file.exist?).must_equal false
    end
  end
  
  private
  
  def mock_result(stdout: '', stderr: '', exit_code: 0)
    result = Object.new
    result.stubs(:stdout).returns(stdout)
    result.stubs(:stderr).returns(stderr)
    result.stubs(:exit_code).returns(exit_code)
    result
  end
  
  def mock_file_info
    { mode: 0644, size: 1024, mtime: Time.now }
  end
end
```

### Coverage Configuration
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

### Test Structure Example
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

# Make your changes, commit them with DCO sign-off
git add .
git commit -s -m "JIRA-12345: Brief description of changes"

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

### Step 3: Unit Test Creation & Validation
- Create comprehensive test cases for all new code
- Ensure test coverage > 80%
- Run tests to verify they pass: `bundle exec rake test`
- Fix any failing tests or coverage issues
- Verify no existing tests are broken by changes
- **Prompt**: "Tests created and passing. Coverage verified > 80%. Next step: Code quality & linting. Ready to proceed? (y/n)"

### Step 4: Code Quality & Linting
- **MANDATORY**: Run RuboCop linting before creating PR
- Execute `bundle exec rake lint` to check for style and formatting issues
- Run `bundle exec rake lint:auto_correct` to automatically fix correctable violations
- Review and manually fix any remaining RuboCop violations
- Ensure all code passes linting standards and style guidelines
- Verify no new linting violations are introduced
- **Prompt**: "Code quality checks complete. Next step: Documentation. Ready to proceed? (y/n)"

### Step 5: Documentation
- Add appropriate code documentation
- Update README if needed
- Create/update relevant documentation files
- **Prompt**: "Documentation complete. Next step: PR creation. Ready to proceed? (y/n)"

### Step 6: PR Creation
- Create branch using JIRA ID as branch name
- Commit and push changes with DCO sign-off
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
- **Ruby**: Primary language (Ruby >= 3.1.0)
- **Minitest**: Primary testing framework
- **SimpleCov**: Code coverage tool (enabled only when CI_ENABLE_COVERAGE=1)
- **Bundler**: Ruby dependency management
- **Rake**: Ruby build tool
- **Mocha**: Mocking framework
- **ChefStyle/RuboCop**: Ruby code style enforcement and linting

## Supported Transports
- Local execution
- SSH
- WinRM
- Docker and Podman
- Mock (for testing)
- AWS API
- Azure API
- VMware via PowerCLI
- Habitat

## Best Practices
- Follow existing code patterns in the repository
- Use meaningful variable and method names
- Handle errors gracefully using Train's error classes
- Write clear, concise code with appropriate comments
- Ensure cross-platform compatibility when applicable

## Error Handling

- Always implement proper error handling using Train's error classes
- Use appropriate error types: `Train::TransportError`, `Train::UserError`
- Log errors appropriately for debugging
- Provide meaningful error messages to users
- Handle transport-specific error conditions

### Common Error Patterns

```ruby
# Configuration validation errors
raise Train::UserError, "Missing required option: #{option}" if opts[option].nil?

# Connection errors
begin
  establish_connection
rescue SomeNetworkError => e
  raise Train::TransportError, "Failed to connect: #{e.message}"
end

# Command execution errors
def run_command_via_connection(cmd, &_data_handler)
  begin
    result = execute_command(cmd)
    CommandResult.new(result.stdout, result.stderr, result.exit_code)
  rescue CommandExecutionError => e
    CommandResult.new('', e.message, 1)
  end
end

# File operation errors
def file_via_connection(path)
  begin
    file_info = get_file_info(path)
    FileCommon.new(self, path, file_info)
  rescue FileNotFoundError
    FileCommon.new(self, path, follow_symlink: false)
  end
end
```

## Security Considerations

- Never commit sensitive information (credentials, keys)
- Use environment variables for configuration
- Follow security best practices for transport development
- Validate all inputs appropriately
- Handle authentication securely
- Consider security implications of new transports

## Additional Best Practices

1. **Version Control**
   - Make atomic commits with clear messages
   - Include JIRA ID in commit messages
   - **MANDATORY**: Always use DCO sign-off with `git commit -s`
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

## Train-Specific Development Guidelines

### Transport Implementation Patterns

When implementing a new transport, follow this structure:

```ruby
module Train::Transports
  class YourTransport < Train.plugin(1)
    name 'your_transport'
    
    # Configuration options
    option :host, required: true
    option :port, default: 443
    option :ssl, default: true
    
    def connection(state = {})
      opts = merge_options(options, state || {})
      validate_options!(opts)
      
      if @connection && reusable?
        @connection
      else
        @connection = Connection.new(opts)
      end
    end
    
    private
    
    def validate_options!(opts)
      # Validate required options
      super(opts)
      # Add transport-specific validations
    end
  end
  
  class Connection < BaseConnection
    def initialize(opts)
      super(opts)
      @options = opts
      # Initialize transport-specific connection
    end
    
    def platform
      # Implement platform detection
      force_platform!('your_platform', platform_details)
    end
    
    def run_command_via_connection(cmd, &_data_handler)
      # Implement command execution
      # Return CommandResult object
    end
    
    def file_via_connection(path)
      # Implement file operations
      # Return FileCommon object
    end
    
    private
    
    def connect
      # Establish connection
    end
    
    def disconnect
      # Clean up connection
    end
  end
end
```

### Platform Registration

For new transports, ensure platform family registration:

```ruby
# In lib/train/platforms/detect/specifications/api.rb
module Train::Platforms::Detect::Specifications
  class Api < Train::Platforms::Detect::Specifications::OS
    def platform_detect
      return false unless @backend.class.to_s == 'Train::Transports::YourTransport::Connection'
      
      @platform[:name] = 'your_platform'
      @platform[:family] = 'api'
      @platform[:family_hierarchy] = %w{your_platform api}
      true
    end
  end
end
```

### Transport Development
- Follow the plugin architecture pattern
- Use Train's connection management
- Implement proper platform detection
- Handle authentication securely
- Support Train's file and command interfaces
- Provide meaningful error messages
- **IMPORTANT**: Register new platform families in `lib/train/platforms/detect/specifications/api.rb`
- Use Train's configuration validation system (`validate_options!`)
- Implement proper connection lifecycle management (connect, disconnect, etc.)
- Support both URI-style and hash-style connection options
- Handle transport-specific errors with appropriate Train exception types
- Consider timeout and retry mechanisms for network-based transports

### Platform Support
- Consider cross-platform compatibility
- Test on multiple operating systems when applicable
- Use Train's platform detection system
- Handle platform-specific edge cases

### Plugin Development
- Follow Train's plugin registration system
- Provide proper plugin metadata
- Use semantic versioning
- Include comprehensive tests

## Validation and Testing Commands

### Essential Commands
```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rake test

# Run tests with coverage (locally)
CI_ENABLE_COVERAGE=1 bundle exec rake test

# Run linting
bundle exec rake lint

# Auto-fix linting issues
bundle exec rake lint:auto_correct
```
```

### Documentation Requirements
- **MANDATORY**: Add comprehensive documentation for all new features
- Add YARD documentation for public methods and classes using proper syntax
- Document transport-specific options, configuration, and usage examples
- Update README.md if adding user-facing features or new transports
- Create or update relevant documentation in `docs/` directory for major features
- Include clear usage examples and code samples that are tested and functional
- Document platform compatibility and requirements
- Add troubleshooting guides for common issues and error scenarios
