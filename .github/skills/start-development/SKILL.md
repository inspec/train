---
name: start-development
description: Configure the repo for AI development. Do this before doing any work in the repo.
---

You are a tool that helps the user setup the development environment for AI-driven development.

You will do several tasks to set the user up.

First, determine if the user is running Windows, MacOS, or Linux. Use that information to decide what scripts to run.

## Load env file if present

Read eny env vars from etc/env.sh if present or etc/env.default.sh if not. You should source this in any shell you run.

## Setup gh

### Install gh

Install the gh GitHub CLI tool if it is not already installed.

### Ensure gh is authenticated

Make sure `gh auth status` works, and run `gh auth login` if not.

## Clone the shared-context repo

### Determine the location of the shared-context repo

The shared context repo location is at $PROGRESS_SHARED_CONTEXT_REPO which looks like org/repo@branch (branch defaults to main).

If no value is present, this defaults to `chef/shared-context@main`

### Clone, Re-Remote, Or Pull

If there are local changes, warn and do nothing.

If context/shared does not exist, clone the repo into it.

If it does exist confirm it is on the right remote and switch.

If it does exist confirm it is on the git branch and switch.

Pull.

## Ensure the list of reference repos is checked out

Look for the file `etc/reference-repo-list.txt`. Re-read the repo list each time you run — it may have changed. It is a list of GitHub repos to clone. Some of them may be private or internal; you may not have access. The list may include branch specifications like @branch.

Try to clone each one into `context/reference-repos`. If it has already been cloned, pull it. If a branch has been specified, make sure you are on that branch. If it has local changes, inform the user and do nothing.

Each time you run, check the repo status again. Do not remove repos, only add them.

## Ensure the Atlassian MCP server is running

Check for `.vscode/mcp.json` and look for the atlassian entry. If it is not running or has errored, ask the user to restart it.

## Ensure the user has rbenv installed and configured

Check if `rbenv` is installed by running `rbenv --version`. If it is not installed, install it using the appropriate method for your operating system. On MacOS, you can use `brew install rbenv`. After installation, ensure that `rbenv` is properly configured by adding `eval "$(rbenv init -)"` to your shell configuration file (e.g., `.bashrc`, `.zshrc`).

## Look for the ruby-version file to determine the currently supported ruby version and ask if it is not set.

Look for the file `.ruby-version` in the root of the repo. It should have a number like 3.4.8 or similar. If the file does not exist, ask the user what the current version of Ruby is for Chef products, and create the file with that version. Default to 3.4.8 if the user does not know.

## Ensure the user has the current ruby installed

Use `rbenv version` to check the currently installed Ruby version. If it does not match the version specified in `.ruby-version`, install the correct version using `rbenv install <version>`. You may need to update the ruby build system to get the latest versions of Ruby by running `brew upgrade rbenv ruby-build` on MacOS.

## Run bundle install using script 

Run `bash .github/scripts/bundle-install.sh`

**Note:** Use the wrapper script instead of `bundle install` directly — it clears VS Code/Copilot git environment variables that break bundler's bare repository clones.
