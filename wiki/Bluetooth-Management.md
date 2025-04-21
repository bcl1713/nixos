---
title: Bluetooth Management
---

# Bluetooth Management

This guide explains how to use the Bluetooth device management system included in this NixOS configuration.

## Overview

The Bluetooth management module provides a seamless experience for connecting and managing Bluetooth devices with:

- Simple GUI and CLI tools for device management
- Waybar integration with status indicator
- Audio device integration with PipeWire
- Convenient keyboard shortcuts
- Automatic service management

## Enabling Bluetooth Support

To enable Bluetooth support, add the following to your `home.nix`:

```nix
userPackages.utilities.bluetooth = {
  enable = true;
  # Other options as needed
};
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable the Bluetooth module |
| `autostart.enable` | boolean | `true` | Automatically start Bluetooth service on login |
| `audio.enable` | boolean | `true` | Enable audio support for Bluetooth devices |
| `gui.enable` | boolean | `true` | Enable GUI tools for Bluetooth management |
| `gui.blueman.enable` | boolean | `true` | Use Blueman for Bluetooth management |
| `waybar.enable` | boolean | `true` | Show Bluetooth indicator in Waybar |

## Command-Line Tools

The module includes several convenient command-line tools:

### bluetooth-toggle

Toggles Bluetooth on and off:

```bash
bluetooth-toggle
```

### bluetooth-pair

Starts the device pairing process:

```bash
bluetooth-pair
```

If GUI is enabled, this will launch the Blueman pairing assistant. Otherwise, it uses a Wofi-based device selector.

## Keyboard Shortcuts

When using Hyprland, the following keyboard shortcuts are available:

| Shortcut | Action |
|----------|--------|
| `Super+Shift+B` | Toggle Bluetooth on/off |
| `Super+Ctrl+B` | Start pairing process |

## Waybar Integration

The Waybar Bluetooth indicator shows the current status:

- Blue icon: Bluetooth enabled but not connected
- Green icon: Bluetooth connected to device(s)
- Gray icon: Bluetooth disabled

Click the icon to toggle Bluetooth on/off, or right-click to start pairing.

## Audio Integration

When `audio.enable = true`, Bluetooth audio devices are automatically integrated with PipeWire for seamless audio switching.

To manage audio devices and output routing:

1. Connect your Bluetooth audio device
2. Use PulseAudio volume control (`pavucontrol`) to select the device
3. The system will remember your device for future connections

## Troubleshooting

### Device Not Connecting

If a device won't connect:

1. Ensure Bluetooth is enabled: `bluetoothctl show`
2. Check if the device is discoverable/in pairing mode
3. Try removing and re-pairing: 
   ```bash
   bluetoothctl devices
   bluetoothctl remove XX:XX:XX:XX:XX:XX
   bluetooth-pair
   ```

### Audio Issues

For Bluetooth audio problems:

1. Check if the device is connected: `bluetoothctl info XX:XX:XX:XX:XX:XX`
2. Verify PipeWire is running: `systemctl --user status pipewire`
3. Check audio routing in `pavucontrol`
4. Try reconnecting the device: `bluetoothctl disconnect XX:XX:XX:XX:XX:XX && bluetoothctl connect XX:XX:XX:XX:XX:XX`

## System Requirements

- Bluetooth hardware (built-in or USB adapter)
- BlueZ package (automatically installed by this module)
- PipeWire for audio support (automatically configured)
