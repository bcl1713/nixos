---
title: External Drive Management
---

# External Drive Management

This guide explains how to use the external drive management system included in this NixOS configuration.

## Overview

The external drive management module provides a comprehensive solution for handling removable media and external drives with:

- Automatic mounting of USB drives and other removable media
- GUI tools for drive management (formatting, partitioning)
- Safe unmounting and ejection workflows
- Notifications for drive events
- Terminal utilities for advanced drive operations
- Hyprland integration for quick access to drive management

## Enabling External Drive Support

To enable external drive support, add the following to your `home.nix`:

```nix
userPackages.utilities.externalDrives = {
  enable = true;
  # Other options as needed
};
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable external drive management |
| `autoMount.enable` | boolean | `true` | Automatically mount drives when connected |
| `gui.enable` | boolean | `true` | Enable graphical tools for drive management |
| `notifications.enable` | boolean | `true` | Show notifications for drive events |
| `terminal.enable` | boolean | `true` | Enable terminal utilities for drive management |

## Command-Line Tools

The module includes several convenient command-line utilities:

### safe-unmount

Safely unmount and optionally eject drives:

```bash
# Simply unmount a drive
safe-unmount /dev/sdb1

# Unmount by mount point
safe-unmount /run/media/user/DRIVE_LABEL

# Unmount and power off (eject)
safe-unmount --eject /dev/sdb1
```

### list-drives

List all mounted external drives:

```bash
list-drives
```

This will show information about connected drives including size, mount point, and labels.

## Automounting Behavior

When `autoMount.enable = true`, drives will be automatically mounted when connected. The service uses `udiskie` in the background to handle mounting with these features:

- Automatic mounting on connection
- Support for various filesystems (ext4, NTFS, exFAT, FAT32)
- Proper handling of permissions for the current user
- Optional notifications on mount events

## GUI Drive Management

When `gui.enable = true`, these graphical tools are available:

- **GNOME Disks** (`gnome-disk-utility`): For partitioning, formatting, and managing drives
- **Thunar Volume Manager** (when using Hyprland): For integration with Thunar file manager

To launch GNOME Disks:

```bash
gnome-disks
```

## Notifications

When `notifications.enable = true`, you'll receive desktop notifications for:

- Drive connection events
- Drive removal events
- Successful mount operations
- Successful unmount operations

These notifications use the system notification daemon (like Mako or Dunst) and include helpful information about the drive.

## Hyprland Integration

When using Hyprland, you can access drive management functions with a keyboard shortcut:

- Press `Super + U` to show a menu with drive options:
  - Mount all drives
  - Unmount all drives
  - Show connected drives
  - Open disk utility

## Supported Filesystems

The module supports these filesystem types out of the box:

- ext2/3/4
- NTFS (with ntfs3g driver)
- exFAT
- FAT32 (vfat)
- XFS
- Btrfs

## Troubleshooting

### Drive Not Mounting

If a drive doesn't mount automatically:

1. Check if `udiskie` service is running: `systemctl --user status udiskie`
2. Try mounting manually: `udisksctl mount -b /dev/sdXY`
3. Check drive filesystem: `lsblk -f`
4. Verify drive isn't corrupted: `dmesg | tail`

### Safely Removing Drives

Always unmount drives before physically disconnecting them:

1. Use the `safe-unmount` command
2. Or use the `Super + U` menu in Hyprland
3. Or right-click the drive in your file manager and select "Unmount"

### Permission Issues

If you encounter permission errors:

1. Check if your user is in the correct groups: `groups`
2. You should be in the `plugdev` group for device access
3. Try running `udisksctl mount -b /dev/sdXY` to see specific error messages

## Additional Resources

- [udisks2 Documentation](https://storaged.org/doc/udisks2-api/latest/)
- [GNOME Disks Manual](https://help.gnome.org/users/gnome-help/stable/disk.html)
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
