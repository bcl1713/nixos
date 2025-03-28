# Changelog

All notable changes to this NixOS configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-03-24

### Added
- Firefox browser configuration with privacy enhancements
- Creative applications module with PrusaSlicer support
- Git configuration with commit templates and hooks
- Productivity apps with Nextcloud client integration
- Markdown support in Neovim with zen mode and preview
- Terminal configuration with Kitty terminal
- Directory combiner utility script

### Changed
- Improved Hyprland configuration with Catppuccin theme
- Enhanced Neovim configuration with better LSP support
- Restructured module organization for better maintainability
- Updated documentation to reflect new modules

### Fixed
- Battery warning script detection logic
- Nextcloud client startup issues
## [0.2.0] - 2025-03-19

### Added
- Automatic garbage collection (nix.gc) to prevent store bloat
- ZRam support for improved memory management
- Git integration for Neovim (gitsigns, fugitive, diffview)
- Battery warning notification system
- Mako notification daemon with Catppuccin theme
- Enhanced TLP power management settings
- Git commit message template and hooks
- New git aliases and configuration options

### Changed
- Updated README with new todo list for enhancements
- Updated README with a link to the CHANGELOG for better documentation navigation
- Improved Neovim keymap organization with which-key integration
- Updated README to reflect new features and improvements
- Reorganized Hyprland autostart configuration

### Fixed
- Path issues in git hooks setup

## [0.1.0] - 2025-03-15

### Added
- Initial NixOS configuration with Hyprland
- Home Manager integration
- Modular structure for system and user configurations
- Neovim setup with LSP support
- Waybar configuration with Catppuccin theme
- Firefox with privacy enhancements
- Custom scripts (wifi-menu, directory-combiner)
- Kitty terminal with theme
- Basic shell configuration with zsh
