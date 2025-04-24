# NixOS Home-Manager Configuration

A modular and extensible NixOS home-manager configuration with a focus on productivity, development, and customization.

![Version](https://img.shields.io/badge/version-0.5.0-blue)
![NixOS](https://img.shields.io/badge/NixOS-compatible-success)

## Overview

This repository contains a comprehensive NixOS Home-Manager configuration structured as modular components. The configuration is designed to be easily extensible and customizable, with a focus on development tools, productivity applications, and a seamless desktop experience.

## Features

### Applications

- **Browsers**: Firefox with privacy enhancements, telemetry disabling, and DNS-over-HTTPS
- **Development**: Git with commit templates and hooks, VSCode, and language-specific tools
- **Creative**: Support for creative applications like PrusaSlicer
- **Productivity**: Nextcloud client with systemd integration
- **Terminal**: Kitty terminal with custom font and theme

### Development Environment

- **Languages**: Support for Nix, Node.js, Python, and Markdown
- **Tools**: Code formatting, linting, and development utilities
- **Git**: Comprehensive Git configuration with conventional commits
- **GitHub**: CLI utility for GitHub workflow integration

### Editor Configuration

- **Neovim**: Full-featured Neovim setup with:
  - LSP (Language Server Protocol) support
  - Code completion and snippets
  - Git integration
  - Markdown support with preview, zen mode, and table editing
  - File navigation and telescope integration
  - Syntax highlighting with Treesitter

### Window Manager

- **Hyprland**: Wayland compositor with:
  - Catppuccin Mocha theme
  - Custom keybindings
  - Waybar integration
  - Screen locking with swaylock and swayidle

### Utilities

- **Scripts**:
  - `wifi-menu`: Interactive WiFi connection manager
  - `battery-warning`: Low battery notification system
  - `combine-directory`: Utility to recursively combine directory contents
  = `update-output-file`: Script to generate output file with directory contents
  and github issues
- **Clipboard Management**:
  - Clipboard history with Clipman integration

### System Integration

- **Fonts**: Nerd Fonts integration with FiraCode
- **Media**: Audio, video, and image tooling
- **System Utilities**: Core system tools and integration

## Structure

The configuration is organized into modular components:

```
packages/
├── apps/               # Application configurations
│   ├── browser/        # Browser configurations (Firefox)
│   ├── creative/       # Creative applications
│   ├── development/    # Development applications
│   ├── productivity/   # Productivity applications
│   └── terminal/       # Terminal emulators
├── development/        # Development environments
├── editors/            # Editor configurations
│   └── neovim/         # Neovim configuration and plugins
├── fonts/              # Font configurations
├── media/              # Media tools
├── scripts/            # Custom scripts and utilities
├── system/             # System configurations
├── utilities/          # Utility packages
└── wm/                 # Window manager configurations
    └── hyprland/       # Hyprland configuration
```

## Installation

1. Ensure you have [NixOS](https://nixos.org/) with [Home-Manager](https://github.com/nix-community/home-manager) installed
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/nixos-config.git ~/.config/nixos
   ```
3. Import the configuration in your `home.nix`:
   ```nix
   {
     imports = [ 
       ./path/to/packages/default.nix
     ];
     
     # Your other configurations...
   }
   ```
4. Apply the configuration:
   ```bash
   home-manager switch
   ```

## Customization

Each module includes options that can be enabled or disabled. For example, to disable Firefox:

```nix
{
  userPackages.apps.browser.firefox.enable = false;
}
```

Or to change Git settings:

```nix
{
  userPackages.apps.development.git = {
    userName = "Your Name";
    userEmail = "your.email@example.com";
    defaultBranch = "main";
  };
}
```

## Utilities

### Directory Combiner

A utility to recursively combine all files in a directory with headers showing relative paths.

```bash
combine-directory [OPTIONS] <directory> [output-file]
```

Options:
- `-a, --all`: Include hidden files and directories
- `-h, --help`: Show help message

Example:
```bash
combine-directory --all ~/projects/my-code combined-output.txt
```

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for a detailed history of changes.

## License

[MIT](./LICENSE)

## Acknowledgements

- [NixOS](https://nixos.org/)
- [Home-Manager](https://github.com/nix-community/home-manager)
- [Hyprland](https://hyprland.org/)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
