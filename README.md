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

- **Hybrid Graphics Support** with Intel/NVIDIA configuration
  - NVIDIA offload for running specific applications on the dedicated GPU
  - Power-efficient configuration to extend battery life
- **Hyprland Wayland compositor** with a Catppuccin Mocha theme
- **Proper screen sharing support** for video conferencing apps like Google Meet
- **Home Manager** integration for user configuration
- **Modular structure** that separates system and user configurations
- **Full NixOS reproducibility** with flakes
- **Neovim** configured for coding and markdown editing
  - LSP integration with consistent keymap prefixes
  - Telescope fuzzy finder with organized mappings
  - Oil.nvim for file navigation
  - Markdown tools (preview, tables, zen mode)
  - Which-key for discoverable keybindings
  - Git integration with gitsigns, fugitive, and diffview
- **Waybar** with custom styling and battery indicators
- **Firefox** with enhanced privacy settings
- **Kitty** terminal emulator with Catppuccin theme
- **Declarative user scripts** for enhanced workflow
- **System optimizations**:
  - Automatic garbage collection
  - ZRam support for better memory management
  - Advanced TLP settings for improved battery life
  - Automated low battery notifications

## 🧱 Structure

```
.
├── flake.lock                     # Lock file for reproducable builds
├── flake.nix                      # Entry point for the configuration
├── profiles                       # System profiles
│   └── personal                   # Personal profile configuration
│       ├── configuration.nix      # Main system configuration
│       ├── hardware-configuration.nix
│       └── home.nix               # Home manager configuration
└── user                           # User-specific configurations
    ├── app                        # Application configurations
    │   ├── firefox
    │   ├── git
    │   ├── kitty
    │   ├── neovim
    │   ├── nextcloud
    │   └── prusa
    ├── fonts                      # Font configuration
    ├── packages
    │   ├── default.nix            # Main entry point for package modules
    │   ├── development            # Development tools
    │   ├── media                  # Media applications
    │   ├── system                 # System utilities
    │   └── utilities              # General utilities
    ├── scripts                    # Custom utility scripts
    │   ├── battery-warning.nix    # Low battery notification service
    │   ├── directory-combiner.nix # File combining utility
    │   └── wifi-menu.nix          # Wofi-based WiFi selector
    └── wm                         # Window manager (Hyprland) configuration
        └── hyprland
            ├── swaylock           # Swaylock configuration
            └── waybar             # Waybar configuration
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

### Package Management

Each module can be individually enabled in the profile configuration:

```nix
userPackages = {
    enable = true;
    development = {
        enable = true;
        python.enable = true;
        # Other options...
    };
    # Other module optioins...
};
```


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

- **battery-warning**: Automatically runs in the background to monitor battery levels
  and send notifications when battery is low

### Neovim

The Neovim configuration includes:

- LSP support for multiple languages
- Telescope for fuzzy finding
- Oil.nvim for file navigation
- Markdown-specific enhancements
- Catppuccin color scheme
- Custom keybindings
- Git integration with gitsigns, fugitive, and diffview

## ⌨️ Keyboard Shortcuts

### Neovim

My Neovim configuration uses consistent keymap prefixes to organize commands:

| Prefix      | Description                                              |
|-------------|----------------------------------------------------------|
| `<leader>l` | LSP operations (rename, format, symbols, etc.)           |
| `<leader>f` | File/Find operations (files, grep, buffers, etc.)        |
| `<leader>g` | Git operations (stage, reset, diff, blame, etc.)         |
| `<leader>m` | Markdown-specific operations (preview, tables, zen mode) |
| `<leader>d` | Diagnostics operations                                   |
| `<leader>b` | Buffer operations                                        |
| `<leader>w` | Window operations                                        |
| `<leader>e` | File explorer (oil.nvim)                                 |

#### Common Keymaps

| Shortcut          | Action                              |
|-------------------|-------------------------------------|
| `<leader><space>` | Find files                          |
| `<leader>/`       | Search text                         |
| `<leader>e`       | Open file explorer                  |
| `-`               | Navigate to parent directory in Oil |
| `<leader>w`       | Save file                           |
| `<leader>q`       | Quit                                |
| `<C-h/j/k/l>`     | Navigate between windows            |
| `<leader>wv`      | Split window vertically             |
| `<leader>ws`      | Split window horizontally           |

#### LSP Keymaps

| Shortcut     | Action                   |
|--------------|--------------------------|
| `<leader>lr` | Rename symbol            |
| `<leader>la` | Code action              |
| `<leader>lf` | Format document          |
| `<leader>ls` | Document symbols         |
| `gd`         | Go to definition         |
| `gr`         | Find references          |
| `K`          | Show hover documentation |

#### Diagnostics

| Shortcut     | Action                |
|--------------|-----------------------|
| `<leader>df` | Show line diagnostics |
| `<leader>dl` | List all diagnostics  |
| `[d`         | Previous diagnostic   |
| `]d`         | Next diagnostic       |

#### Markdown-specific

| Shortcut     | Action                  |
|--------------|-------------------------|
| `<leader>mp` | Toggle markdown preview |
| `<leader>mt` | Toggle table mode       |
| `<leader>mr` | Realign tables          |
| `<leader>mz` | Toggle zen mode         |
| `<leader>mx` | Toggle checkbox         |

#### Git Operations

| Shortcut         | Action                             |
|------------------|-----------------------------------|
| `<leader>gs`     | Stage hunk                        |
| `<leader>gr`     | Reset hunk                        |
| `<leader>gS`     | Stage buffer                      |
| `<leader>gu`     | Undo stage hunk                   |
| `<leader>gR`     | Reset buffer                      |
| `<leader>gp`     | Preview hunk                      |
| `<leader>gb`     | Blame line                        |
| `<leader>gt`     | Toggle current line blame         |
| `<leader>gd`     | Diff against index                |
| `<leader>gD`     | Diff against previous commit      |
| `<leader>gcc`    | Create commit                     |
| `<leader>gca`    | Amend commit                      |
| `<leader>gll`    | View git log                      |
| `<leader>glf`    | View git log for current file     |
| `<leader>glp`    | View git log with patches         |
| `<leader>gvd`    | Open diffview                     |
| `<leader>gvh`    | View file history                 |
| `<leader>gvc`    | Close diffview                    |
| `[c`             | Jump to previous hunk             |
| `]c`             | Jump to next hunk                 |

### Hyprland

| Shortcut              | Action                           |
|-----------------------|----------------------------------|
| `Super + Return`      | Open terminal                    |
| `Super + C`           | Close active window              |
| `Super + Space`       | Open application launcher (wofi) |
| `Super + E`           | Open file manager                |
| `Super + B`           | Open browser                     |
| `Super + V`           | Toggle floating mode             |
| `Super + 1-0`         | Switch to workspace 1-10         |
| `Super + Shift + 1-0` | Move window to workspace 1-10    |
| `Super + S`           | Toggle special workspace         |
| `Super + h/j/k/l`     | Focus window in direction        |
| `Super + Mouse wheel` | Cycle through workspaces         |
| `Super + X`           | Lock screen                      |

### Volume and Brightness

| Shortcut             | Action                   |
|----------------------|--------------------------|
| `Volume Up/Down`     | Change volume by 5%      |
| `Volume Mute`        | Toggle mute              |
| `Brightness Up/Down` | Change brightness by 10% |

### GPU Management

You can run applications on the NVIDIA GPU by using the `nvidia-offload`
command:

```bash
# Example: Run Firefox on the NVIDIA GPU
nvidia-offload firefox

# Example: run a game with NVIDIA GPU
nvidia-offload steam
```


## 📦 Included Packages

- **Core**: Hyprland, Waybar, kitty, wofi
- **Applications**: Firefox, Neovim, git
- **File Management**: nautilus
- **Development**: Nix LSP, Lua LSP, Markdown LSP
- **Productivity**: NextCloud client
- **Media**: PulseAudio, PipeWire
- **Notifications**: Mako with Catppuccin theme
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
5. Update the Mako notification theme in `user/wm/hyprland/hyprland.nix`

## 🔄 Recent Changes

See the [CHANGELOG.md](./CHANGELOG.md) for a detailed list of recent changes and improvements.

## 📝 Todo / Future Improvements

### New Features
- [ ] Add secrets management with agenix or sops-nix
- [ ] Implement Bluetooth management and add a Waybar applet
- [ ] Configure a backup system using restic, borgbackup, or rsync
- [ ] Implement password manager integration with browser support

### Refinements
- [ ] Organize packages into logical groups (development, media, utilities)
- [ ] Expand flake outputs to support multiple machines (desktop/laptop/server)
- [ ] Add git hooks for linting and validating Nix code
- [ ] Configure additional language-specific development environments
- [ ] Add media tools (mpv, audio configuration with wireplumber)
- [ ] Configure PDF tools (viewer, editor, converter)
- [ ] Improve documentation with comprehensive keybinding reference

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Neovim Documentation](https://neovim.io/doc/)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE.md](./LICENSE.md) file for details.
