---
title: Development Environment
---

# Development Environment

This guide explains the development tools and configurations included in this NixOS setup.

## Overview

The development environment is designed to provide a comprehensive, language-agnostic setup with specific optimizations for commonly used languages. It includes:

- Language-specific toolchains and LSP servers
- Git and GitHub integration
- Neovim configuration with IDE-like features
- Terminal utilities for development

## Module Structure

The development modules are organized as follows:

```
user/packages/development/
├── default.nix       # Core development module
├── github.nix        # GitHub CLI integration
└── ...               # Future language-specific modules

user/packages/editors/
├── default.nix       # Core editors module
└── neovim/           # Neovim configuration
    ├── default.nix   # Neovim module
    └── lua/          # Lua configurations for Neovim
        ├── options.lua     # Core options
        └── plugin/         # Plugin configurations
            ├── lsp.lua     # LSP configuration
            ├── cmp.lua     # Completion system
            ├── git.lua     # Git integration
            └── ...         # Other plugin configurations
```

## Basic Configuration

Enable development tools in your `home.nix`:

```nix
userPackages = {
  development = {
    enable = true;
    nix.enable = true;       # Nix development tools
    markdown.enable = true;  # Markdown support
    nodejs.enable = true;    # Node.js development
    python.enable = true;    # Python development
    tooling.enable = true;   # General development tools
  };
  
  editors = {
    enable = true;
    neovim = {
      enable = true;
      plugins = {
        enable = true;
        lsp.enable = true;     # Language Server Protocol
        git.enable = true;     # Git integration
        markdown.enable = true; # Markdown support
      };
    };
  };
};
```

## Language Support

### Nix Development

When `development.nix.enable = true`, the following tools are installed:

- `nixfmt-classic`: Formatter for Nix files
- `nil`: Nix Language Server for IDE features

### Python Development

When `development.python.enable = true`, the following tools are installed:

- Python 3 with pip
- Black (code formatter)
- Flake8 (linter)

### Node.js Development

When `development.nodejs.enable = true`, the following tools are installed:

- Node.js runtime
- npm package manager
- Yarn package manager

### General Tooling

When `development.tooling.enable = true`, the following tools are installed:

- `ripgrep`: Fast search tool (used by Neovim's Telescope)
- `fd`: Alternative to `find`
- `jq`: JSON processor
- `direnv`: Environment switcher

## Git Configuration

Git is configured through the `userPackages.apps.development.git` module:

```nix
userPackages.apps.development.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  defaultBranch = "main";
  enableCommitTemplate = true;
  enableCommitHooks = true;
};
```

### Features

- **Commit Templates**: Standardized commit message format
- **Commit Hooks**: Validation of commit messages against conventional format
- **Global Configuration**: Consistent Git settings across projects

### Commit Message Format

The commit template follows the conventional commits format:

```
<type>[(optional scope)]: <description>
|<---- Using a Maximum Of 50 Characters ---->|

[optional body]
|<---- Try To Limit Each Line to a Maximum Of 72 Characters ---->|

[optional footer(s)]
```

Types include:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## GitHub Integration

GitHub CLI is provided through the `userPackages.development.github` module:

```nix
userPackages.development.github = {
  enable = true;
  enableCompletions = true;
};
```

This includes:
- GitHub CLI (`gh`) for interacting with GitHub
- Shell completions for GitHub CLI commands

## Neovim Configuration

Neovim is configured as a modern IDE with extensive plugin support:

### Core Features

- **LSP Support**: Language Server Protocol for intelligent code analysis
- **Autocompletion**: Context-aware suggestions via nvim-cmp
- **Syntax Highlighting**: Treesitter-based parsing and highlighting
- **File Navigation**: Telescope fuzzy finder and file browser
- **Git Integration**: Gitsigns, Fugitive, and Diffview

### LSP Configuration

Language Server Protocol support is provided for:

- Lua (lua-language-server)
- Nix (nil and nixd)
- YAML (yaml-language-server)
- Markdown (marksman)

Each LSP provides:
- Code completion
- Error diagnostics
- Go to definition
- Find references
- Documentation on hover
- Code formatting

### Key Mappings

Neovim uses a consistent key mapping structure:

- `<Space>` as the leader key
- `<leader>l` prefix for LSP operations
- `<leader>f` prefix for file operations (find, grep)
- `<leader>g` prefix for Git operations
- `<leader>b` prefix for buffer operations
- `<leader>w` prefix for window operations

Common LSP operations:
- `gd`: Go to definition
- `gr`: Find references
- `K`: Show hover documentation
- `<leader>lr`: Rename symbol
- `<leader>la`: Code action
- `<leader>lf`: Format document

## Terminal Integration

The development environment integrates with the terminal configuration:

- Kitty terminal with developer-friendly settings
- ZSH with helpful aliases for development
- Git status in prompt

## Docker and Container Support

For Docker and container development, you can enable additional components:

```nix
# In your configuration
virtualisation.docker.enable = true;
users.users.yourusername.extraGroups = [ "docker" ];

# Additional tools
home.packages = with pkgs; [
  docker-compose
  lazydocker  # TUI for Docker
];
```

## Database Tools

For database development:

```nix
# In your home.nix
home.packages = with pkgs; [
  pgcli           # PostgreSQL client
  mycli           # MySQL client
  sqlite          # SQLite
  dbeaver         # Database GUI
];
```

## Creating Project Templates

You can create project templates for common development scenarios:

1. Create a templates directory:
   ```bash
   mkdir -p ~/.config/dev-templates
   ```

2. Create a template generator script:
   ```bash
   # ~/.local/bin/create-project
   #!/usr/bin/env bash
   
   TEMPLATE_DIR="$HOME/.config/dev-templates"
   
   # List available templates
   templates=$(ls "$TEMPLATE_DIR")
   
   if [ "$#" -lt 2 ]; then
     echo "Usage: create-project <template> <project-name>"
     echo "Available templates:"
     for template in $templates; do
       echo "  - $template"
     done
     exit 1
   fi
   
   template="$1"
   project_name="$2"
   
   if [ ! -d "$TEMPLATE_DIR/$template" ]; then
     echo "Template '$template' not found"
     exit 1
   fi
   
   # Create project directory
   mkdir -p "$project_name"
   cp -r "$TEMPLATE_DIR/$template/"* "$project_name/"
   
   # Replace placeholder with project name
   find "$project_name" -type f -exec sed -i "s/PROJECT_NAME/$project_name/g" {} \;
   
   echo "Project '$project_name' created from template '$template'"
   ```

3. Make it executable:
   ```bash
   chmod +x ~/.local/bin/create-project
   ```

4. Create template directories for each project type:
   ```bash
   mkdir -p ~/.config/dev-templates/node-ts
   mkdir -p ~/.config/dev-templates/python-flask
   # Add files to each template directory
   ```

## Language-Specific Setup

### Python Environment

For Python development:

1. Create virtual environments:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   ```

2. Use `direnv` for automatic environment activation:
   ```bash
   # In .envrc
   use python
   layout python3
   ```

### Node.js Environment

For Node.js development:

1. Initialize a project:
   ```bash
   npm init
   # or
   yarn init
   ```

2. Use `direnv` for environment management:
   ```bash
   # In .envrc
   use nodejs
   layout node
   ```

## Debugging Support

For debugging applications:

```nix
# In your home.nix
home.packages = with pkgs; [
  gdb             # GNU Debugger
  lldb            # LLVM Debugger
  vscode-fhs      # VSCode with FHS environment for debugging
];
```

## Performance Optimizations

To improve development experience:

1. **Editor Performance**:
   - Limit plugins to what you need
   - Configure LSP to ignore large directories (node_modules, .git)

2. **Build Performance**:
   - Use `cachix` for binary caches
   - Configure parallel builds in Nix

3. **Development Workflow**:
   - Use `direnv` for project-specific environment variables
   - Set up shell aliases for common tasks

## Best Practices

1. **Project Structure**:
   - Maintain consistent project layouts
   - Use `.editorconfig` for consistent formatting

2. **Version Control**:
   - Follow conventional commits
   - Use meaningful branch names
   - Write descriptive commit messages

3. **Documentation**:
   - Document your code
   - Create README files for projects
   - Maintain a development journal

4. **Testing**:
   - Write unit tests for your code
   - Set up CI/CD pipelines for automated testing

5. **Environment Management**:
   - Use `.envrc` files with direnv
   - Create reproducible environments with Nix

## Additional Resources

- [Nix Language Reference](https://nixos.org/manual/nix/stable/language/index.html)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Neovim Documentation](https://neovim.io/doc/)
- [LSP Specifications](https://microsoft.github.io/language-server-protocol/)
