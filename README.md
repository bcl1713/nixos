# NixOS Configuration

> A modern, reproducible and modular NixOS configuration with Hyprland

![Hyprland](https://img.shields.io/badge/WM-Hyprland-blue)
![NixOS](https://img.shields.io/badge/OS-NixOS-6ad7e5)
![Home Manager](https://img.shields.io/badge/Tool-Home_Manager-41BDF5)
![License](https://img.shields.io/badge/License-MIT-green)

This repository contains my personal NixOS configuration for a laptop setup running Hyprland. The configuration is modular, extensible, and built with Nix flakes for reproducibility.

## 📸 Screenshots

- [ ] Add Screenshots

## ✨ Features

- **Hyprland Wayland compositor** with a Catppuccin Mocha theme
- **Home Manager** integration for user configuration
- **Modular structure** that separates system and user configurations
- **Full NixOS reproducibility** with flakes
- **Neovim** configured for coding and markdown editing
- **Waybar** with custom styling and battery indicators
- **Firefox** with enhanced privacy settings
- **Kitty** terminal emulator with Catppuccin theme
- **Declarative user scripts** for enhanced workflow

## 🧱 Structure

```
.
├── flake.nix                 # The entry point for the configuration
├── flake.lock                # Lock file for reproducible builds
├── profiles                  # System profiles
│   └── personal              # Personal profile configuration
│       ├── configuration.nix # Main system configuration
│       ├── home.nix          # Home manager configuration
│       └── hardware-configuration.nix
└── user                      # User-specific configurations
    ├── app                   # Application configurations
    │   ├── firefox
    │   ├── git
    │   ├── kitty
    │   ├── neovim
    │   ├── nextcloud
    │   └── prusa
    ├── fonts                 # Font configuration
    ├── scripts               # Custom utility scripts
    └── wm                    # Window manager (Hyprland) configuration
        └── hyprland
            ├── waybar        # Waybar configuration
            └── ...
```

## 📋 Installation

### Prerequisites

- NixOS installed on your system
- Git

### Setup

1. Clone this repository:

```bash
git clone https://github.com/yourusername/nixos-config.git ~/.dotfiles
```

2. Build and switch to the configuration:

```bash
cd ~/.dotfiles
sudo nixos-rebuild switch --flake .#nixbook
```

3. Apply user configuration using Home Manager:

```bash
home-manager switch --flake .#brianl
```

## 🚀 Usage

### System Management

- Rebuild and switch to the system configuration:
  ```bash
  sudo nixos-rebuild switch --flake ~/.dotfiles/
  ```
  or use the alias:
  ```bash
  nss
  ```

- Update Home Manager configuration:
  ```bash
  home-manager switch --flake ~/.dotfiles/
  ```
  or use the alias:
  ```bash
  hms
  ```

### Custom Scripts

- **wifi-menu**: A Wofi-based WiFi network selector
  ```bash
  wifi-menu
  ```

- **directory-combiner**: Recursively combine files in a directory with headers
  ```bash
  combine-directory /path/to/directory output.txt
  ```

### Neovim

The Neovim configuration includes:

- LSP support for multiple languages
- Telescope for fuzzy finding
- Oil.nvim for file navigation
- Markdown-specific enhancements
- Catppuccin color scheme
- Custom keybindings

## ⌨️ Keyboard Shortcuts

### Hyprland

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open terminal |
| `Super + C` | Close active window |
| `Super + Space` | Open application launcher (wofi) |
| `Super + E` | Open file manager |
| `Super + B` | Open browser |
| `Super + V` | Toggle floating mode |
| `Super + 1-0` | Switch to workspace 1-10 |
| `Super + Shift + 1-0` | Move window to workspace 1-10 |
| `Super + S` | Toggle special workspace |
| `Super + h/j/k/l` | Focus window in direction |
| `Super + Mouse wheel` | Cycle through workspaces |

### Volume and Brightness

| Shortcut | Action |
|----------|--------|
| `Volume Up/Down` | Change volume by 5% |
| `Volume Mute` | Toggle mute |
| `Brightness Up/Down` | Change brightness by 10% |

## 📦 Included Packages

- **Core**: Hyprland, Waybar, kitty, wofi
- **Applications**: Firefox, Neovim, git
- **File Management**: nautilus
- **Development**: Nix LSP, Lua LSP, Markdown LSP
- **Productivity**: NextCloud client
- **Media**: PulseAudio, PipeWire
- **Other**: Prusa Slicer, various fonts

## 🔧 Customization

### Adding a New Application

1. Create a new directory under `user/app/your-application/`
2. Create a Nix file with the configuration (e.g., `your-application.nix`)
3. Import it in your profile's `home.nix`

### Changing the Theme

The configuration uses the Catppuccin Mocha theme. To change it:

1. Modify the color variables in `user/wm/hyprland/hyprland.nix`
2. Update the Waybar theme in `user/wm/hyprland/waybar/`
3. Change the terminal theme in `user/app/kitty/kitty.nix`
4. Update the Neovim theme in `user/app/neovim/nvim/plugin/catppuccin.lua`

## 📝 Todo / Future Improvements

- [ ] Add screen sharing support
- [ ] Implement automatic garbage collection
- [ ] Create a dashboard for Neovim
- [ ] Add Git integration for Neovim
- [ ] Improve battery notifications
- [ ] Configure ZRam for better performance
- [ ] Implement a backup solution
- [ ] Add GPU acceleration optimizations
- [ ] Configure development environments with devenv.sh
- [ ] Set up container management with Podman

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Neovim Documentation](https://neovim.io/doc/)

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
