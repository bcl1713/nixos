---
title: Tailscale Configuration
---

# Tailscale Configuration

This guide explains how to use and configure the Tailscale VPN integration in this NixOS setup.

## Overview

[Tailscale](https://tailscale.com/) is a zero-config VPN that makes it easy to securely connect devices across different networks. This configuration provides a comprehensive Tailscale setup with:

- System-level Tailscale daemon
- Automatic connection at startup
- Secret management using Agenix
- Waybar integration for status monitoring
- Convenient command-line utilities

## Basic Configuration

The Tailscale integration can be enabled in your `home.nix`:

```nix
userPackages.utilities.tailscale = {
  enable = true;
  autoConnect.enable = true;
  acceptRoutes = true;
  waybar.enable = true;
};
```

## Authentication Setup

### Creating the Auth Key

1. Log in to the [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
2. Go to "Settings" → "Auth Keys"
3. Create a new auth key (recommended settings):
   - One-time use: No (allows reconnection)
   - Ephemeral: No (persistent node)
   - Expiry: Set according to your security policy (e.g., 90 days)
   - Tags: Add any relevant tags for this device

### Setting Up the Auth Key with Agenix

1. Once you have an auth key, store it using Agenix:

```bash
# Create the secret file (replace with your actual key)
echo "tskey-auth-abcdefghijkl123456" > tailscale-auth-key

# Encrypt it with agenix
agenix -e secrets/tailscale-auth-key.age
```

2. Configure your `home.nix` to use this secret:

```nix
age = {
  identityPaths = [ "/home/${userSettings.username}/.ssh/id_ed25519" ];
  secrets = {
    # Other secrets...
    tailscale-auth-key = { file = ../../secrets/tailscale-auth-key.age; };
  };
};

userPackages.utilities.tailscale = {
  enable = true;
  autoConnect = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-auth-key.path;
  };
  # Other options...
};
```

## Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable Tailscale integration |
| `autoConnect.enable` | boolean | `true` | Automatically connect on startup |
| `autoConnect.authKeyFile` | path | `null` | Path to the auth key file |
| `useExitNode` | boolean | `false` | Route all traffic through an exit node |
| `exitNode` | string | `""` | Hostname of the exit node to use |
| `acceptRoutes` | boolean | `true` | Accept advertised routes from other nodes |
| `waybar.enable` | boolean | `true` | Show Tailscale status in Waybar |

## Command-Line Utilities

This integration provides several convenient command-line utilities:

| Command | Description |
|---------|-------------|
| `tailscale-connect` | Connect to Tailscale (auto-authenticates if configured) |
| `tailscale-disconnect` | Disconnect from Tailscale |
| `tailscale-toggle-exit` | Toggle exit node on/off |
| `tailscale-status` | Show Tailscale connection status |

Additionally, these shell aliases are available:

| Alias | Command |
|-------|---------|
| `ts-status` | `tailscale status` |
| `ts-up` | `tailscale-connect` |
| `ts-down` | `tailscale-disconnect` |
| `ts-exit` | `tailscale-toggle-exit` |

## Waybar Integration

When `waybar.enable = true`, a Tailscale status indicator is added to Waybar:

- Green: Connected to Tailscale
- Red: Disconnected
- Click to connect
- Right-click to disconnect

## System Integration

The configuration includes:

1. System-level Tailscale daemon via `services.tailscale.enable = true`
2. Firewall configuration with `services.tailscale.openFirewall = true`
3. Automatic route acceptance with `services.tailscale.useRoutingFeatures = "client"`

## Troubleshooting

### Connection Issues

If Tailscale fails to connect:

1. Check the service status: `systemctl status tailscaled`
2. Verify the auth key: `sudo tailscale status`
3. Check Tailscale logs: `journalctl -u tailscaled`
4. Ensure the auth key has not expired

### Permission Issues

If you encounter permission errors:

1. Verify the auth key file permissions: `ls -la /run/agenix/tailscale-auth-key`
2. Ensure your user has sudo access for Tailscale commands
3. Check that `services.tailscale.enable = true` in your system configuration

## Advanced Usage

### Using Exit Nodes

To route all traffic through an exit node:

1. Set up an exit node in your Tailscale network
2. Configure your client to use it:

```nix
userPackages.utilities.tailscale = {
  enable = true;
  useExitNode = true;
  exitNode = "exit-node-hostname";
};
```

3. Toggle exit node usage with `tailscale-toggle-exit`

### Subnet Routing

To advertise local subnets:

1. Edit your system configuration:

```nix
services.tailscale = {
  enable = true;
  openFirewall = true;
  useRoutingFeatures = "server";
};
```

2. Enable IP forwarding:

```nix
boot.kernel.sysctl = {
  "net.ipv4.ip_forward" = 1;
  "net.ipv6.conf.all.forwarding" = 1;
};
```

3. Advertise your subnet:

```bash
sudo tailscale up --advertise-routes=192.168.1.0/24
```
