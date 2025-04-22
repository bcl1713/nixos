# Changelog

All notable changes to this NixOS configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Keybinding cheatsheet generator with multiple display formats
- Command-line utility to show keyboard shortcuts
- Integration with wofi/rofi for searchable keybinding reference
- Documentation for keybinding cheatsheet feature
- Automatic detection of system features for relevant shortcuts
- Comprehensive Bluetooth device management with GUI and CLI tools
- Waybar status indicator for Bluetooth connections
- Bluetooth pairing and connection workflow
- Bluetooth audio integration with PipeWire
- Documentation for Bluetooth and peripherals management
- Tailscale VPN integration with automatic connection
- Agenix secret management for Tailscale auth key
- Waybar status indicator for Tailscale
- Command-line utilities for managing Tailscale connection
- Documentation for Tailscale configuration and usage
## [0.4.0] - 2025-04-06

### Added
- Wiki for advanced topics and usage information
- Configuration Basics
- Comprehensive documentation for all configuration options
- Configuration examples for common use cases
- Disk usage analysis and management tools
- Enhanced system update management with Home Manager integration
- Unified update command for bot NixOS and Home Manager
- Configurable update notifications system
- Maintenance utilities including automatic garbage collection
- Convenient shell aliases for system updates
- Documentation for update system
- System resource monitoring with CPU, memory, disk, and temperature metrics
- Waybar integration for monitoring system resources with Nerd Font icons
- Terminal-based monitoring tools (htop, btop, bottom)
- Graphical monitoring tools (gnome-system-monitor, glances)
- `system-stats` command for quick terminal-based system overview
- Rofi application launcher with Catppuccin theme
- Emoji picker integration with rofimoji
- Cliboard manager with history support for Wayland using Clipman
- Hyprland integration for clipbaord history via Super+V
- GitHub CLI utility with aliases and shell completions
- Output file generator script to combine directory contents and github issues
- Emoji picker for wofi
- Window picker for wofi
- Screen recording functionality
- Lid close suspend on battery and power, but not docked
- Enhanced power management with profile switching and waybar integration
- Bitwarden password manager integration with desktop app and CLI tools

### Changed
- Reorganized system update logic to work with existing system.autoUpgrade
settings
- Temporarily disabled wofi in favor of rofi until feature parody
- Refactored scripts module by splitting output-generator into a separate file
- Removed tools..nix and simplified scripts module structure
- Improved modularity by moving script implementations to dedicated files
- Migrated wofi to utilities

### Fixed

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
