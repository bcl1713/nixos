---
title: Update Management
---

# Update Management

This guide explains how the system update process works and how to manage updates effectively.

## Update System Overview

This configuration includes an enhanced update management system that handles both NixOS system updates and Home Manager updates. The system provides convenient tools, notifications, and maintenance utilities to keep your system up-to-date and optimized.

## Update Commands

### Basic Update Commands

The following shell aliases are available for easy updates:

- `update-all`: Update both NixOS system and Home Manager
- `update-home`: Update only Home Manager
- `update-nixos`: Update only the NixOS system

These commands are wrapper scripts around the standard NixOS and Home Manager update commands with additional features.

### Command Options

The `update-system` script (called by `update-all`) accepts these options:

- `--system-only`: Update only the NixOS system
- `--home-only`: Update only Home Manager
- `--reboot`: Reboot after updates (with confirmation)

Example usage:

```bash
# Update everything
update-all

# Update only NixOS with reboot after
update-nixos --reboot
```

## Automatic Updates

### System Auto-Updates

The system is configured with automatic updates through the NixOS `system.autoUpgrade` service. By default, it:

- Runs at 04:00 daily
- Does not automatically reboot after updates
- Updates only system components (not Home Manager)

You can customize this behavior in your configuration:

```nix
# In profiles/personal/configuration.nix
system.autoUpgrade = {
  enable = true;
  allowReboot = false;  # Set to true to allow reboots
  dates = "04:00";      # When to run updates
};
```

### Home Manager Auto-Updates

Home Manager updates can also be scheduled:

```nix
# In your home.nix
userPackages.utilities.systemUpdates = {
  enable = true;
  homeManager = {
    enable = true;
    frequency = {
      weekday = "daily";  # Options: daily, weekly, monthly, or specific day
      time = "04:30";     # Time in 24-hour format
    };
  };
};
```

## Update Notifications

The update system includes notifications for update events:

```nix
userPackages.utilities.systemUpdates = {
  notifications = {
    enable = true;
    beforeUpdate = true;  # Notify before updates start
    afterUpdate = true;   # Notify when updates complete
  };
};
```

These notifications help you stay informed about the update process without having to monitor it directly.

## Maintenance Tasks

### Garbage Collection

The system can automatically perform garbage collection to free disk space:

```nix
userPackages.utilities.systemUpdates.maintenance = {
  garbageCollection = {
    enable = true;
    maxAge = 30;          # Days to keep old generations
    frequency = "weekly"; # How often to run garbage collection
  };
};
```

You can also manually run garbage collection:

```bash
# User-level garbage collection
nix-gc

# System-wide garbage collection (requires sudo)
sudo nix-collect-garbage --delete-older-than 30d
```

### Store Optimization

Store optimization reduces disk usage by creating hard links between identical files:

```nix
userPackages.utilities.systemUpdates.maintenance = {
  optimizeStore = true;
};
```

To run store optimization manually:

```bash
sudo nix-store --optimize
```

## Understanding Update Logs

Update logs are stored in several locations:

- **System updates**: `/var/log/nixos-rebuild.log`
- **Home Manager**: `~/.local/state/home-manager/home-manager.log`
- **Systemd service logs**: `journalctl -u nixos-upgrade`

To view Home Manager update logs:

```bash
less ~/.local/state/home-manager/home-manager.log
```

To view system update logs:

```bash
sudo less /var/log/nixos-rebuild.log
journalctl -u nixos-upgrade
```

## Rollbacks

If an update causes issues, you can roll back to a previous generation:

### System Rollbacks

```bash
# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Roll back to the previous generation
sudo nixos-rebuild switch --rollback

# Roll back to a specific generation
sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation 123
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

### Home Manager Rollbacks

```bash
# List home-manager generations
home-manager generations

# Roll back to previous generation
home-manager generations | head -n1 | cut -d' ' -f7 | xargs -I{} {}

# Roll back to a specific generation
home-manager switch --generation 42
```

## Testing Updates Before Applying

To test updates without applying them:

```bash
# Test system updates
sudo nixos-rebuild test --flake ~/.dotfiles/

# Test Home Manager updates
home-manager build --flake ~/.dotfiles/
```

These commands build the updates but don't activate them, allowing you to check for build errors.

## Managing Channels

If you're using channels alongside flakes, you may need to update channels:

```bash
# Update all channels
sudo nix-channel --update
nix-channel --update

# Update specific channel
sudo nix-channel --update nixos
nix-channel --update home-manager
```

## Updating Flake Inputs

To update flake inputs manually:

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
nix flake lock --update-input home-manager
```

After updating flake inputs, rebuild your system:

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles/
home-manager switch --flake ~/.dotfiles/
```

## Troubleshooting Update Issues

### Failed System Updates

If a system update fails:

1. Check logs: `journalctl -u nixos-upgrade`
2. Try with more verbose output: `sudo nixos-rebuild switch -v --flake ~/.dotfiles/`
3. Check for network issues: `ping nixos.org`
4. Try clearing the build directory: `rm -rf /tmp/nix-build-*`

### Failed Home Manager Updates

If a Home Manager update fails:

1. Check the home-manager log: `less ~/.local/state/home-manager/home-manager.log`
2. Try with verbose output: `home-manager switch -v --flake ~/.dotfiles/`
3. Check for specific errors related to packages or configurations
4. Try rebuilding with: `home-manager build --no-out-link --flake ~/.dotfiles/`

### Fixing Broken Dependencies

If you encounter broken dependencies:

1. Update the channel or flake input for the relevant package
2. Check if the package has been renamed or deprecated
3. Consider using an overlay to fix or modify the package
4. Look for alternative packages that provide the same functionality

## Best Practices

1. **Regular updates**: Update your system regularly to avoid large, potentially problematic updates
2. **Backup configuration**: Before major updates, commit your configuration changes to git
3. **Incremental updates**: Update one component at a time when possible
4. **Test updates**: Use `nixos-rebuild test` to check for issues before applying
5. **Keep generations**: Maintain several generations for easy rollback
6. **Monitor disk space**: Run garbage collection periodically to free disk space
7. **Update during downtime**: Schedule updates when you're not actively using the system
8. **Review changelogs**: Check release notes for major NixOS or Home Manager versions
