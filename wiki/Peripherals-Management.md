---
title: Peripherals Management
---

# Peripherals Management

This guide explains how to use the peripherals management system included in this NixOS configuration, with a focus on RGB lighting control for gaming devices.

## Overview

The peripherals management module provides tools for customizing and controlling various input devices:

- Corsair devices (including Harpoon mouse) using ckb-next
- Logitech devices using Solaar
- Razer devices using OpenRazer

## Enabling Peripherals Support

To enable peripherals support, add the following to your `home.nix`:

```nix
userPackages.utilities.peripherals = {
  enable = true;
  
  # Enable specific device support
  corsair.enable = true;  # For Corsair devices
  logitech.enable = true; # For Logitech devices
  razer.enable = true;    # For Razer devices
};
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable peripherals management |
| `corsair.enable` | boolean | `false` | Enable Corsair device support |
| `corsair.autostart` | boolean | `true` | Automatically start Corsair services |
| `logitech.enable` | boolean | `false` | Enable Logitech device support |
| `razer.enable` | boolean | `false` | Enable Razer device support |

## Corsair Devices

### Corsair Harpoon Mouse LED Control

The module includes specialized tools for controlling Corsair Harpoon mouse LEDs:

```bash
# Basic usage
corsair-mouse-led <color> [animation]

# Examples
corsair-mouse-led red       # Static red color
corsair-mouse-led blue pulse   # Pulsing blue effect
corsair-mouse-led "#00ff00" breathe # Breathing green effect
corsair-mouse-led cyan wave     # Wave effect with cyan color
```

Supported color names: red, green, blue, yellow, magenta, cyan, white, off, or any hex color code like "#ff0000".

Supported animations: static, breathe, pulse, wave

### Corsair Profile Presets

For quick LED configuration, use the profile tool:

```bash
# Apply a predefined profile
corsair-profile <profile>

# Available profiles
corsair-profile gaming   # Red pulsing effect
corsair-profile work     # Blue static effect
corsair-profile night    # Purple breathing effect
corsair-profile rainbow  # Rainbow wave effect
corsair-profile off      # Turn off LEDs
```

### CKB-Next GUI

For more advanced configuration, you can use the CKB-Next GUI:

```bash
ckb-next
```

This will open a graphical interface where you can:
- Create custom lighting effects
- Configure DPI settings
- Program button macros
- Save and load profiles

## Logitech Devices

When `logitech.enable = true`, the Solaar application is installed for managing Logitech devices:

```bash
solaar
```

This provides:
- Battery status monitoring
- Device pairing
- Advanced settings for supported devices
- Unified receiver management

## Razer Devices

When `razer.enable = true`, OpenRazer and Polychromatic are installed:

```bash
# GUI tool
polychromatic-controller
```

Features include:
- RGB lighting control
- Macro programming
- Device-specific settings
- Profile management

## Troubleshooting

### Corsair Devices Not Detected

If ckb-next doesn't detect your Corsair devices:

1. Check if the device is connected
2. Restart the ckb-next daemon:
   ```bash
   systemctl --user restart ckb-next
   ```
3. Verify permissions for the USB device

### LED Control Not Working

If LED commands have no effect:

1. Ensure ckb-next daemon is running:
   ```bash
   pgrep -x ckb-next || systemctl --user start ckb-next
   ```
2. Try restarting the daemon and reconnecting your device
3. Check if your device is supported by ckb-next

## Additional Resources

- [CKB-Next Documentation](https://github.com/ckb-next/ckb-next/wiki)
- [Solaar GitHub Repository](https://github.com/pwr-Solaar/Solaar)
- [OpenRazer Documentation](https://openrazer.github.io/)
