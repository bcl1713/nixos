---
title: Installation Guide
---

# Installation Guide

This guide will walk you through the process of installing and setting up the NixOS Home-Manager configuration.

## Prerequisites

Before you begin, make sure you have:

- A working [NixOS](https://nixos.org/) installation (Recommended version: 24.05 or later)
- [Home Manager](https://github.com/nix-community/home-manager) installed
- Basic understanding of the Nix language and NixOS configuration
- Git installed on your system

## System Requirements

- **CPU**: Any modern x86_64 processor (Intel/AMD)
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: At least 30GB of free space
- **GPU**: For Hyprland to work best, a GPU with Wayland support is recommended

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/nixos-config.git ~/.config/nixos
cd ~/.config/nixos
```

### 2. Initial Configuration

Create a personal profile or use the existing one:

```bash
# If using the existing personal profile:
cp -r profiles/personal profiles/myprofile
```

Update the system settings in `flake.nix`:

```nix
systemSettings = { profile = "myprofile"; };
userSettings = {
  username = "yourusername";
  name = "Your Name";
  email = "your.email@example.com";
};
```

### 3. Apply the Configuration

For a system-wide installation:

```bash
sudo nixos-rebuild switch --flake .#nixbook
```

For Home Manager only:

```bash
home-manager switch --flake .#yourusername
```

### 4. Post-Installation

After installation, you should reboot your system to ensure all changes take effect:

```bash
sudo reboot
```

## Updating the Configuration

To update your configuration after making changes:

```bash
# For system configuration:
sudo nixos-rebuild switch --flake ~/.config/nixos/

# For Home Manager configuration:
home-manager switch --flake ~/.config/nixos/
```

Or use the custom update scripts provided:

```bash
# Update both system and home manager:
update-all

# Update home manager only:
update-home

# Update system only:
update-nixos
```

## Troubleshooting Installation Issues

### Flake Command Not Found

If you encounter `error: flake is not available`, enable flakes in your Nix configuration:

```nix
# In configuration.nix or home.nix
nix = {
  settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
};
```

### Home Manager Not Found

If Home Manager commands aren't recognized, make sure it's properly installed:

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

### Hyprland Issues

If Hyprland fails to start:

1. Ensure Wayland is properly supported by your hardware
2. Check the Hyprland logs: `cat ~/.local/share/hyprland.log`
3. Try starting with a minimal configuration: `Hyprland -c /dev/null`

### Repository Authentication

If you encounter authentication issues with the repository:

```bash
# Generate an SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add the key to your GitHub account
cat ~/.ssh/id_ed25519.pub
# Copy the output and add it to GitHub
```

## Next Steps

After installation, explore these resources:

- [Configuration Basics](./Configuration-Basics) to learn how to customize your setup
- [Feature Overview](./Feature-Overview) to understand what's included
- Check the main `README.md` file for a quick reference
