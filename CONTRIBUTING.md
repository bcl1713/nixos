# Contributing to NixOS Home-Manager Configuration

Thank you for your interest in contributing to this NixOS Home-Manager configuration! This document provides guidelines and workflows to ensure consistent, high-quality contributions.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Documentation](#documentation)
- [Testing](#testing)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone. Please:

- Be kind, patient, and welcoming to contributors of all skill levels
- Respect differing viewpoints and experiences
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** to your GitHub account
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/nixos-config.git
   cd nixos-config
   ```
3. **Add the upstream repository as a remote**:
   ```bash
   git remote add upstream https://github.com/original-owner/nixos-config.git
   ```
4. **Create a new branch** for your contribution (see [Development Workflow](#development-workflow))

## Development Workflow

Please follow these steps for all contributions:

1. **Always start from the latest develop branch**:
   ```bash
   git checkout develop
   git pull upstream develop
   ```

2. **Create feature branches** with consistent naming:
   ```bash
   git checkout -b feature/v0.4.0/descriptive-name
   ```
   For bug fixes:
   ```bash
   git checkout -b fix/v0.4.0/descriptive-name
   ```

3. **Keep branches focused** on a single feature or bug fix

4. Make your changes, following the [Coding Standards](#coding-standards)

5. **Test your changes** (see [Testing](#testing))

6. **Commit your changes** following the [Commit Guidelines](#commit-guidelines)

7. **Push to your fork**:
   ```bash
   git push origin feature/v0.4.0/descriptive-name
   ```

8. **Create a pull request** to the `develop` branch of the upstream repository

## Coding Standards

### Module Structure

- Place new modules in appropriate directories
- Follow existing patterns in similar modules
- Create submodules when appropriate for complex features

### Configuration Design

- Every module should have an `enable` option defaulting to a sensible value
- Use `mkIf cfg.enable` for conditional configuration
- Group related options logically
- Use descriptive option names

### Implementation Example

```nix
# user/packages/utilities/new-feature.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.newFeature;
in {
  options.userPackages.utilities.newFeature = {
    enable = mkEnableOption "Enable new feature";
    
    setting1 = mkOption {
      type = types.str;
      default = "default value";
      description = "Description of setting1";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ 
      package1
      package2
    ];
    
    # Other configuration...
  };
}
```

### Comment Standards

- Add a header comment to each file explaining its purpose
- Document complex logic or non-obvious configuration choices
- Use consistent comment formatting

## Commit Guidelines

Follow the established commit message format:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc; no code change
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Code change that improves performance
- `test`: Adding missing tests
- `chore`: Changes to the build process or auxiliary tools/libraries
- `ci`: Changes to CI configuration files and scripts

### Rules

- **Scope** should be the module or component being modified
- **Description** should be concise and descriptive in imperative mood
- Keep the first line under 50 characters
- Body lines should be wrapped at 72 characters

### Example Commits

```
feat(rofi): add application launcher with catppuccin theme

docs(README): update with new rofi launcher instructions

fix(battery): correct detection logic for charge status
```

## Pull Request Process

1. **Update output.txt** with the latest state of files:
   ```bash
   combine-directory --all . output.txt
   ```

2. **Push branch** to GitHub:
   ```bash
   git push origin feature/v0.4.0/feature-name
   ```

3. **Create a pull request** to merge into develop:
   ```bash
   gh pr create --title "Feature: Add descriptive name" --body "Description and closes #ISSUE_NUMBER" --base develop
   ```

4. **Wait for review** if working with others, or verify quality if self-reviewing

5. **Address feedback** from reviewers if applicable

6. Once approved, your PR will be merged to the develop branch

## Documentation

Update documentation with every change:

1. **Update CHANGELOG.md** with new entries under [Unreleased] section
2. **Update README.md** if the feature adds user-facing functionality
3. **Create/update module documentation** with:
   - Purpose of the module
   - Available options and their defaults
   - Examples of usage
   - Dependencies or requirements

## Testing

Before considering a feature complete:

1. **Verify the feature works** as expected
2. **Check for configuration errors** by running:
   ```bash
   home-manager build --flake .#brianl
   ```
3. **Test integration** with other system components
4. **Verify documentation** is complete and accurate

## Issue Reporting

When reporting issues:

1. Use the appropriate issue template if available
2. Provide a clear and descriptive title
3. Include detailed steps to reproduce the issue
4. Describe the expected behavior and what actually happened
5. Include relevant logs and system information
6. Label the issue appropriately

---

Thank you for contributing to making this NixOS configuration better!
