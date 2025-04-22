---
title: Keybinding Cheatsheet
---

# Keybinding Cheatsheet

This guide explains how to use the keybinding cheatsheet generator, a tool that helps you discover and remember keyboard shortcuts for your system.

## Overview

The keybinding cheatsheet generator provides an easily accessible reference for all configured keyboard shortcuts in your system, including:

- Hyprland window manager keybindings
- Application keyboard shortcuts
- System utility keybindings
- Custom script shortcuts

The cheatsheet can be displayed in multiple formats, making it accessible regardless of your workflow preferences.

## Basic Usage

### Accessing the Cheatsheet

By default, you can access the keybinding cheatsheet by pressing:

```
Super + F1
```

This will display the cheatsheet in the default format (terminal).

### Command Line Usage

You can also run the cheatsheet generator from the command line with different output options:

```bash
# Display in terminal with syntax highlighting
keybinding-cheatsheet terminal

# Display using wofi (requires wofi)
keybinding-cheatsheet wofi

# Display using rofi (requires rofi)
keybinding-cheatsheet rofi

# Save as markdown file
keybinding-cheatsheet markdown
```

## Configuration

You can customize the keybinding cheatsheet in your `home.nix`:

```nix
userPackages.scripts.keybindingCheatsheet = {
  enable = true;
  keybinding = "SUPER, F1";  # Change the shortcut key
  defaultFormat = "terminal"; # Options: terminal, wofi, rofi, markdown
  
  # Automatic configuration based on enabled features
  includeScreenRecording = true; # Include screen recording shortcuts
  includeClipboard = true;       # Include clipboard manager shortcuts
  includeBluetooth = true;       # Include Bluetooth controls
  includeTailscale = true;       # Include Tailscale VPN controls
  includePowerProfile = true;    # Include power profile management
};
```

Most options are automatically configured based on your system setup, but you can override them as needed.

## Customizing the Cheatsheet

The cheatsheet extracts information from your actual configuration when possible, ensuring that the displayed shortcuts match your system setup.

### Adding Custom Keybindings

If you have custom keybindings that aren't automatically detected, you can modify the script at:

```
~/.config/nixos/user/packages/scripts/keybinding-cheatsheet.nix
```

Look for the `extract_custom_bindings` function to add your unique shortcuts.

## Display Formats

### Terminal Display

The terminal display uses `glow` to render the markdown with syntax highlighting in your terminal. This is ideal for quick reference during development.

### Wofi/Rofi Display

The wofi and rofi displays provide a searchable overlay interface that can be quickly summoned and dismissed. This is perfect for checking a specific keybinding without losing your place in your workflow.

### Markdown Export

The markdown export saves the cheatsheet to a file, which you can then view with any markdown viewer or editor. This is useful for printing or sharing your keybinding configuration.

## Troubleshooting

### Keybindings Not Showing

If your keybindings aren't displayed correctly, check:

1. If you're using custom configuration formats that the parser doesn't recognize
2. If the keybindings are defined in files outside the standard locations
3. If you have renamed or modified standard configuration files

### Display Issues

If the display format doesn't work correctly:

- For terminal display: Ensure `glow` is installed
- For wofi display: Ensure `wofi` is installed and properly configured
- For rofi display: Ensure `rofi-wayland` is installed and properly configured

## Related Topics

- [Hyprland Configuration](./Hyprland-Configuration.md)
- [Customization](./Customization.md)
- [Shortcuts](./Shortcuts.md)
