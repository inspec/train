
### Code Quality Standards

#### Ruby Standards
- **Supported Ruby**: the authoritative requirement is the gemspec floor —
  `required_ruby_version >= 3.1.0` (both `train.gemspec` and `train-core.gemspec`).
  Target `>= 3.1.0`. (Note: a local `.ruby-version` file may be present for
  developer convenience, but it is untracked/gitignored and **not** authoritative —
  don't treat it as the supported-version pin.)
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
