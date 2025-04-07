---
title: Configuration Basics
---

# Configuration Basics

This guide explains the fundamental concepts of the configuration system and how to effectively customize your setup.

## Core Concepts

This NixOS configuration is built on several key principles:

1. **Modularity**: Features are organized into self-contained modules
2. **Enable Flags**: Most features can be toggled on/off with `enable` options
3. **Sensible Defaults**: Everything works out of the box with reasonable defaults
4. **Progressive Disclosure**: Simple options for common tasks, detailed options for advanced needs

## Configuration Structure

The configuration is structured hierarchically:

```
userPackages
├── apps
│   ├── browser
│   ├── development
│   ├── terminal
│   └── ...
├── development
├── editors
├── fonts
├── media
├── scripts
├── system
├── utilities
└── wm
```

## Basic Configuration

Most configuration happens in your `home.nix` file. Here's a simple example:

```nix
# In profiles/personal/home.nix
userPackages = {
  wm = {
    enable = true;
    hyprland.enable = true;
    waybar.enable = true;
  };
  
  editors = {
    enable = true;
    neovim.enable = true;
  };
  
  apps = {
    browser.firefox.enable = true;
    terminal.kitty.enable = true;
  };
};
```

## Common Configuration Patterns

### Enabling/Disabling Features

Most modules and submodules have an `enable` option:

```nix
# Enable Firefox but disable privacy features
userPackages.apps.browser.firefox = {
  enable = true;
  privacy.enable = false;
};

# Disable Wofi but enable Rofi
userPackages.utilities = {
  wofi.enable = false;
  rofi.enable = true;
};
```

### Setting Simple Options

Many modules have basic configuration options:

```nix
# Configure Git
userPackages.apps.development.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  defaultBranch = "main";
};

# Configure Kitty terminal
userPackages.apps.terminal.kitty = {
  enable = true;
  font = {
    family = "JetBrains Mono Nerd Font";
    size = 12;
  };
};
```

### Configuring Complex Features

More complex features may have nested options:

```nix
# Configure system update behavior
userPackages.utilities.systemUpdates = {
  enable = true;
  
  homeManager = {
    enable = true;
    frequency = {
      weekday = "daily";
      time = "04:30";
    };
  };
  
  notifications = {
    enable = true;
    beforeUpdate = true;
    afterUpdate = true;
  };
  
  maintenance = {
    garbageCollection = {
      enable = true;
      maxAge = 30;
      frequency = "weekly";
    };
    optimizeStore = true;
  };
};
```

## Finding Available Options

To discover what options are available:

1. Check the [Configuration Options](./Configuration-Options) reference
2. Explore the module source code in the repository
3. Use the `home-manager option` command:
   ```bash
   home-manager option userPackages.editors.neovim
   ```

## Applying Changes

After modifying your configuration, apply changes with:

```bash
# Update Home Manager configuration
home-manager switch --flake ~/.config/nixos/

# Or use the provided shortcut
update-home
```

## Configuration Best Practices

1. **Start Simple**: Begin with just the modules you need
2. **Make Incremental Changes**: Modify a few options at a time and test
3. **Check for Errors**: Use `home-manager build` to check for issues before applying
4. **Group Related Changes**: Keep related configuration options together
5. **Use Comments**: Document non-obvious choices

## Example Configurations

### Minimal Desktop

```nix
userPackages = {
  wm = {
    enable = true;
    hyprland.enable = true;
    waybar.enable = true;
  };
  
  utilities = {
    system.enable = true;
    files.enable = true;
    wayland.enable = true;
  };
  
  apps = {
    browser.firefox.enable = true;
    terminal.kitty.enable = true;
  };
  
  fonts.enable = true;
};
```

### Developer Workstation

```nix
userPackages = {
  wm.enable = true;
  
  development = {
    enable = true;
    nix.enable = true;
    python.enable = true;
    nodejs.enable = true;
    github.enable = true;
  };
  
  editors = {
    enable = true;
    neovim = {
      enable = true;
      plugins = {
        lsp.enable = true;
        git.enable = true;
      };
    };
  };
  
  utilities = {
    system = {
      enable = true;
      monitoring.enable = true;
    };
    diskUsage.enable = true;
    systemUpdates.enable = true;
  };
};
```

## Further Reading

- [Module System](./Module-System): Learn about the module architecture
- [Customization](./Customization): Advanced customization techniques
- [Configuration Options](./Configuration-Options): Complete reference of all options
