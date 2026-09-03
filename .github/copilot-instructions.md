# GitHub Copilot Instructions for Train Repository

## Repository Overview

This repository contains the Train Transport Interface, a Ruby library that provides a unified interface to talk to local or remote operating systems and APIs. Train is a core component of the Chef InSpec ecosystem and is used by Chef Infra Client for its Agentless feature.

## Initialization Required

VERY IMPORTANT: If `context/shared/map.md` does not exist, the only skill you are permitted to run is "start-development". All other skills and tasks must run "start-development" first before being allowed to continue. Note that the path to map.md is in a gitignored directory - a directory-listing/glob search will fail to find it - you must view the file directly using the explicit path. If the file is not found, use the /start-development skill.

To get started with AI-driven development, you must initialize the repo with the /start-development skill. This will set up your environment, clone reference repos, and ensure you have the necessary tools installed. The remainder of this document assumes you have done this.

## Dynamic Context Loading

VERY IMPORTANT: This repo uses dynamic context loading using modular, shared context files. Search for information using the /search-context skill. The map of what context files are and what levels of context exist is located at `context/shared/map.md`. You must read and understand this file to understand how to load context. If the file is not found, use the /start-development skill. 

VERY IMPORTANT: Whenever you need to search for information about the project, the codebase, or the domain, you should first consult the shared context files. Use the /search-context skill to do this.
Always use the search-context skill, it knows how to traverse the map.

## Project Information

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
├── context/                              # AI SDLC Context and guidance
│   ├── local/                            # Guidance, research, and advice specific to this repository
│   ├── reference-repos/                  # Reference repositories for AI-assisted development
│   └── shared/                           # Shared context and guidance across projects
├── contrib/                              # Contribution utilities
├── docs/                                 # Documentation
├── etc/                                  # Configuration files for development
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
- **Ruby**: Primary language (Ruby 3.1+, see `.ruby-version` for the currently supported version)
- **Minitest**: Primary testing framework
- **Bundler**: Ruby dependency management
- **Rake**: Ruby build tool
- **Mocha**: Mocking framework
- **ChefStyle**: Ruby code style enforcement and linting

## Development Guidelines

### Workflow

IMPORTANT: follow the SDLC workflow specified by searching for /search-context "workflow", preferring the local workflow.

### Code Quality Standards

IMPORTANT: follow the guidance specified by searching for /search-context "coding-standards", preferring the local coding standards.

### Testing Standards

IMPORTANT: follow the guidance specified by searching for /search-context "testing-standards", preferring the local testing standards.