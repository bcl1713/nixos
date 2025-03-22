# Changelog

All notable changes to this NixOS configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Swaylock screen locking with Catppuccin theme
- Swayidle for automatic screen locking and power management
- Keybinding for manual screen locking
- Proper screen sharing support using xdg-desktop-portal-hyprland

### Fixed

- PAM integrations fixed for unlock on login
- Nextcloud Client service startup fixes
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
