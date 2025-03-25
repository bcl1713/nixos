# Implementing the Configuration Roadmap

This guide outlines consistent workflows and processes to follow when assisting with this NixOS configuration project, particularly for implementing features from the roadmap. Following these guidelines will ensure consistent, high-quality contributions that align with the project's standards.

## Development Workflow

### 1. Feature Selection and Planning

When selecting a feature to implement from the roadmap:

1. **Confirm feature priority** by referencing the ROADMAP.md file
2. **Check GitHub issues** to see if it's already being worked on
3. **Understand dependencies** - identify if the feature depends on other incomplete features
4. **Create a GitHub issue** if one doesn't exist:
   ```
   gh issue create --title "[v0.4.0] Feature Name" --body "Description..." --label "enhancement,v0.4.0,category" --milestone "v0.4.0"
   ```

### 2. Branch Management

1. **Always start from the latest develop branch**:
   ```bash
   git checkout develop
   git pull origin develop
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

### 3. Code Implementation

Follow these standards for all code changes:

1. **Module structure**:
   - Place new modules in appropriate directories
   - Follow existing patterns in similar modules
   - Create submodules when appropriate for complex features

2. **Configuration design**:
   - Every module should have an `enable` option defaulting to a sensible value
   - Use `mkIf cfg.enable` for conditional configuration
   - Group related options logically
   - Use descriptive option names

3. **Implementation example**:
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

4. **Comment standards**:
   - Add a header comment to each file explaining its purpose
   - Document complex logic or non-obvious configuration choices
   - Use consistent comment formatting

### 4. Documentation

Update documentation with every change:

1. **Update CHANGELOG.md** with new entries under [Unreleased] section:
   ```markdown
   ### Added
   - New feature description

   ### Changed
   - Changed feature description

   ### Fixed
   - Fixed bug description
   ```

2. **Update README.md** if the feature adds user-facing functionality

3. **Create/update module documentation** with:
   - Purpose of the module
   - Available options and their defaults
   - Examples of usage
   - Dependencies or requirements

### 5. Testing

Before considering a feature complete:

1. **Verify the feature works** as expected
2. **Check for configuration errors** by running:
   ```bash
   home-manager build --flake .#brianl
   ```
3. **Test integration** with other system components
4. **Verify documentation** is complete and accurate

### 6. Commit Guidelines

Follow the established commit message format:

1. **Use conventional commits**:
   ```
   <type>(<scope>): <description>
   
   [optional body]
   
   [optional footer(s)]
   ```

2. **Types**:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation changes
   - `style`: Formatting, missing semicolons, etc; no code change
   - `refactor`: Code change that neither fixes a bug nor adds a feature
   - `perf`: Code change that improves performance
   - `test`: Adding missing tests
   - `chore`: Changes to the build process or auxiliary tools/libraries
   - `ci`: Changes to CI configuration files and scripts

3. **Scope** should be the module or component being modified

4. **Description** should be concise and descriptive in imperative mood

5. **Example commits**:
   ```
   feat(rofi): add application launcher with catppuccin theme
   
   docs(README): update with new rofi launcher instructions
   
   fix(battery): correct detection logic for charge status
   ```

### 7. Pull Request and Merging

For completing a feature:

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

5. **Merge to develop** once approved:
   ```bash
   gh pr merge --squash
   ```

6. **Close related GitHub issue** if not auto-closed:
   ```bash
   gh issue close ISSUE_NUMBER
   ```

### 8. Release Process

When preparing a version release:

1. **Review unreleased changes** in CHANGELOG.md

2. **Verify all features** planned for the release are complete

3. **Update VERSION file** from `0.4.0-dev` to `0.4.0`

4. **Move [Unreleased] section** in CHANGELOG.md to new version section:
   ```markdown
   ## [0.4.0] - YYYY-MM-DD
   
   ### Added
   ...
   ```

5. **Create final PR** to merge develop into main

6. **Create release tag** on main:
   ```bash
   git checkout main
   git pull origin main
   git tag -a v0.4.0 -m "Release v0.4.0"
   git push origin v0.4.0
   ```

7. **Create GitHub release** with the changelog content

8. **Update VERSION file** in develop to `0.5.0-dev` for continued development

## Feature-Specific Implementation Guides

### Adding a New Application

When adding a new application like Rofi:

1. **Create module file** in appropriate location (e.g., `user/packages/utilities/rofi.nix`)

2. **Define configuration options** with sensible defaults

3. **Add configurations** for the application:
   - Package installation
   - Configuration files
   - Themes
   - Integration with other components

4. **Import module** in the parent module:
   ```nix
   # In user/packages/utilities/default.nix
   { ... }:
   
   {
     imports = [ 
       # Existing imports...
       ./rofi.nix 
     ];
   }
   ```

### Adding Development Tools

When adding development tools like Docker/Podman:

1. **Determine system vs. user configuration**:
   - System-wide services go in `profiles/personal/configuration.nix`
   - User-specific settings go in appropriate user module

2. **Consider security implications**:
   - User group membership
   - Socket permissions
   - Network configuration

3. **Include common configurations**:
   - Daemon settings
   - Performance optimizations
   - Integration with existing development tools

### Creating Theme Management

For theme management implementation:

1. **Create a central theme module** that defines colors and styles

2. **Create theme switching script** that updates configurations

3. **Design application-specific theme implementations**:
   - Terminal
   - Editor
   - Window manager
   - Browser
   - GTK applications

4. **Add file watchers or signals** to reload applications when theme changes

## Common Troubleshooting

When troubleshooting issues:

1. **Check NixOS configuration errors**:
   ```bash
   home-manager build --flake .#brianl
   ```

2. **Verify module imports** are correct

3. **Check file paths** for configuration files

4. **Inspect service status** for running services:
   ```bash
   systemctl --user status service-name
   ```

5. **Review logs** for errors:
   ```bash
   journalctl --user -u service-name
   ```

6. **Test individual components** in isolation when possible

## AI Assistant Notes

When assisting with this project, prioritize:

1. **Maintaining consistent code style** with the existing codebase

2. **Providing complete implementations** rather than partial snippets

3. **Documenting all changes** comprehensively

4. **Suggesting best practices** based on NixOS community standards

5. **Considering modularity** and reusability of configurations

6. **Optimizing package selections** for the system

7. **Maintaining theme consistency** across applications

8. **Providing clear usage instructions** for new features

By following this guide, all contributions will maintain a consistent, high-quality standard that aligns with the project's roadmap and development practices.
