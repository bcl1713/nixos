---
title: Configuration Examples
---

# Configuration Examples

This page provides practical examples for configuring different aspects of the system. These examples demonstrate how to use the configuration options effectively for common use cases.

## Window Manager Configurations

### Basic Hyprland Setup

```nix
userPackages.wm = {
  enable = true;
  hyprland = {
    enable = true;
    swaylock.enable = true;
    swayidle.enable = true;
  };
  waybar.enable = true;
};
```

### Advanced Hyprland with Custom Idle Timeouts

```nix
userPackages.wm = {
  enable = true;
  hyprland = {
    enable = true;
    swaylock.enable = true;
    swayidle = {
      enable = true;
      timeouts = {
        lock = 600;  # 10 minutes before locking screen
        dpms = 900;  # 15 minutes before turning off display
      };
    };
  };
  waybar.enable = true;
};
```

## System Monitoring Configurations

### Basic Monitoring Setup

```nix
userPackages.utilities.system = {
  enable = true;
  monitoring = {
    enable = true;
    topTools.enable = true;      # htop, btop, etc.
    graphical.enable = false;    # No GUI tools
  };
};
```

### Full Monitoring Suite with Waybar Integration

```nix
userPackages.utilities.system = {
  enable = true;
  monitoring = {
    enable = true;
    topTools.enable = true;
    graphical.enable = true;
    waybar = {
      enable = true;
      cpu.enable = true;
      memory.enable = true;
      disk = {
        enable = true;
        mountPoint = "/home";    # Monitor home partition instead of root
      };
      temperature.enable = true;
    };
  };
};
```

## Disk Usage Management

### Minimal Disk Tools

```nix
userPackages.utilities.diskUsage = {
  enable = true;
  interactiveTools.enable = true;    # ncdu, etc.
  graphicalTools.enable = false;
  duplicateFinder.enable = false;
  cleanupTools.enable = true;
};
```

### Comprehensive Disk Management

```nix
userPackages.utilities.diskUsage = {
  enable = true;
  interactiveTools.enable = true;
  graphicalTools.enable = true;      # baobab, etc.
  duplicateFinder.enable = true;     # fdupes, rmlint
  cleanupTools.enable = true;
};
```

## Update Management

### Basic Update Configuration

```nix
userPackages.utilities.systemUpdates = {
  enable = true;
  homeManager.enable = true;
  notifications.enable = true;
};
```

### Advanced Update System with Maintenance

```nix
userPackages.utilities.systemUpdates = {
  enable = true;
  
  homeManager = {
    enable = true;
    frequency = {
      weekday = "daily";
      time = "04:30";
    };
  };
  
  system = {
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "04:00";
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
      maxAge = 14;              # Keep generations for 2 weeks
      frequency = "daily";      # Run daily garbage collection
    };
    optimizeStore = true;
  };
};
```

## Screenshot and Screen Recording

### Basic Screenshot Setup

```nix
userPackages.utilities.screenshot = {
  enable = true;
  # Using default keybindings
};
```

### Custom Screenshot and Recording Configuration

```nix
userPackages.utilities = {
  screenshot = {
    enable = true;
    screenKeybinding = "SUPER, s";          # Changed from default
    areaKeybinding = "SUPER SHIFT, s";
    windowKeybinding = "SUPER ALT, s";
    screenAnnotateKeybinding = "SUPER CTRL, s";
  };
  
  screenRecording = {
    enable = true;
    keybinding = "SUPER, r";                # Changed from default
    areaKeybinding = "SUPER SHIFT, r";
    windowKeybinding = "SUPER ALT, r";
    audioSupport = true;
  };
};
```

## Clipboard Management

### Basic Clipboard Setup

```nix
userPackages.utilities.clipboard = {
  enable = true;
  # Using default configuration
};
```

### Enhanced Clipboard with Large History

```nix
userPackages.utilities.clipboard = {
  enable = true;
  historySize = 50;                # Increased from default 15
  startInBackground = true;
  mimeTypeConfig = true;          # Preserve MIME types for images
};
```

## Power Management

### Basic Power Management

```nix
userPackages.utilities.powerManagement = {
  enable = true;
  # Using default 'balanced' profile
};
```

### Custom Power Management Configuration

```nix
userPackages.utilities.powerManagement = {
  enable = true;
  defaultProfile = "powersave";    # Default to battery saving mode
  keybinding = "SUPER, p";         # Custom keybinding to cycle profiles
  indicator.enable = true;         # Show in waybar
};
```

## Application Launchers

### Basic Wofi Setup

```nix
userPackages.utilities.wofi = {
  enable = true;
  # Using defaults for everything else
};
```

### Rofi with Custom Configuration

```nix
userPackages.utilities = {
  # Disable wofi and use rofi instead
  wofi.enable = false;
  
  rofi = {
    enable = true;
    terminal = "alacritty";        # Use alacritty instead of kitty
    theme = {
      enable = true;
      borderRadius = 12;           # Increased corner rounding
    };
    modes = {
      drun = {
        enable = true;
        keybinding = "SUPER, d";   # Custom keybinding
      };
      window = {
        enable = true;
        keybinding = "ALT, Tab";   # Different from default
      };
      emoji = {
        enable = true;
        keybinding = "SUPER, e";
      };
    };
  };
};
```

## Password Management

### Basic Bitwarden Setup

```nix
userPackages.utilities.bitwarden = {
  enable = true;
  # Using defaults
};
```

### Bitwarden with CLI Focus

```nix
userPackages.utilities.bitwarden = {
  enable = true;
  desktop = {
    enable = false;               # Don't use desktop app
  };
  cli = {
    enable = true;
    addShellAliases = true;       # Add helpful shell aliases
  };
};
```

## Tailscale VPN Configuration

### Basic Tailscale Setup

```nix
userPackages.utilities.tailscale = {
  enable = true;
  # Using defaults for everything else
};
```

### Tailscale with Auto-Connect and Agenix

```nix
# In your home.nix
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
  acceptRoutes = true;
  waybar.enable = true;
};
```

### Tailscale with Exit Node Setup

```nix
userPackages.utilities.tailscale = {
  enable = true;
  autoConnect = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-auth-key.path;
  };
  useExitNode = true;
  exitNode = "exit-node-hostname"; # Replace with your exit node's hostname
  acceptRoutes = true;
  waybar.enable = true;
};
```

## Browser Configuration

### Basic Firefox Setup
=======
## Browser Configuration

### Basic Firefox Setup

```nix
userPackages.apps.browser = {
  enable = true;
  firefox.enable = true;
};
```

### Privacy-Focused Firefox

```nix
userPackages.apps.browser.firefox = {
  enable = true;
  privacy = {
    enable = true;
    disableTelemetry = true;
    disablePocket = true;
    disableAccounts = true;
    dnsOverHttps = {
      enable = true;
      providerUrl = "https://dns.nextdns.io/abc123"; # Custom DNS provider
    };
  };
};
```

## Development Tools Configuration

### Basic Development Setup

```nix
userPackages.development = {
  enable = true;
  nix.enable = true;
  nodejs.enable = true;
};
```

### Comprehensive Development Environment

```nix
userPackages.development = {
  enable = true;
  nix.enable = true;
  markdown.enable = true;
  nodejs.enable = true;
  python.enable = true;
  tooling.enable = true;
  
  github = {
    enable = true;
    enableCompletions = true;
  };
};

userPackages.apps.development.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  defaultBranch = "main";
  enableCommitTemplate = true;
  enableCommitHooks = true;
};
```

## Editor Configuration

### Basic Neovim Setup

```nix
userPackages.editors = {
  enable = true;
  neovim.enable = true;
};
```

### Full-Featured Neovim IDE

```nix
userPackages.editors.neovim = {
  enable = true;
  plugins = {
    enable = true;
    lsp.enable = true;         # Language Server Protocol
    git.enable = true;         # Git integration
    markdown.enable = true;    # Markdown support
  };
};
```

## Terminal Configuration

### Basic Terminal Setup

```nix
userPackages.apps.terminal = {
  enable = true;
  kitty.enable = true;
};
```

### Customized Terminal

```nix
userPackages.apps.terminal.kitty = {
  enable = true;
  font = {
    family = "JetBrainsMono Nerd Font";
    size = 14;                 # Larger font size
  };
  theme = "Tokyo-Night";       # Custom theme
};
```

## Media Tools

### Basic Media Setup

```nix
userPackages.media = {
  enable = true;
  audio.enable = true;
};
```

### Full Media Workstation

```nix
userPackages.media = {
  enable = true;
  audio.enable = true;
  video.enable = true;
  image.enable = true;
};

userPackages.apps.creative = {
  enable = true;
  prusaSlicer.enable = true;
};
```

## Font Configuration

### Basic Font Setup

```nix
userPackages.fonts = {
  enable = true;
  nerdFonts.enable = true;
};
```

### Comprehensive Font Configuration

```nix
userPackages.fonts = {
  enable = true;
  nerdFonts = {
    enable = true;
    firaCode.enable = true;    # Enable FiraCode specifically
  };
  systemFonts.enable = true;
};
```

## Custom Scripts

### Basic Script Setup

```nix
userPackages.scripts = {
  enable = true;
  wifi.enable = true;
  battery.enable = true;
};
```

### Custom Script Configuration

```nix
userPackages.scripts = {
  enable = true;
  wifi.enable = true;
  battery = {
    enable = true;
    lowThreshold = 20;         # Warn at 20% instead of 15%
    criticalThreshold = 10;    # Critical at 10% instead of 5%
  };
  directoryCombiner.enable = true;
  outputGenerator.enable = true;
};
```

## Complete System Examples

### Minimal Laptop Configuration

```nix
userPackages = {
  wm = {
    enable = true;
    hyprland = {
      enable = true;
      swaylock.enable = true;
      swayidle.enable = true;
    };
    waybar.enable = true;
  };
  
  utilities = {
    system.enable = true;
    powerManagement.enable = true;
    screenshot.enable = true;
    clipboard.enable = true;
    bitwarden.enable = true;
    tailscale.enable = true;  # Enable Tailscale VPN
  };
  
  apps = {
    browser.firefox.enable = true;
    terminal.kitty.enable = true;
    productivity.nextcloud.enable = true;
  };
  
  scripts = {
    enable = true;
    wifi.enable = true;
    battery.enable = true;
  };
  
  fonts.enable = true;
};
```

### Developer Workstation Configuration

```nix
userPackages = {
  wm = {
    enable = true;
    hyprland.enable = true;
    waybar.enable = true;
  };
  
  utilities = {
    system = {
      enable = true;
      monitoring = {
        enable = true;
        topTools.enable = true;
        waybar.enable = true;
      };
    };
    diskUsage.enable = true;
    systemUpdates.enable = true;
    screenshot.enable = true;
    screenRecording.enable = true;
    clipboard.enable = true;
    wofi.enable = true;
    tailscale = {
      enable = true;
      autoConnect = {
        enable = true;
        authKeyFile = config.age.secrets.tailscale-auth-key.path;
      };
      acceptRoutes = true;
    };
  };
  
  development = {
    enable = true;
    nix.enable = true;
    python.enable = true;
    nodejs.enable = true;
    markdown.enable = true;
    tooling.enable = true;
    github.enable = true;
  };
  
  editors = {
    enable = true;
    neovim = {
      enable = true;
      plugins = {
        enable = true;
        lsp.enable = true;
        git.enable = true;
        markdown.enable = true;
      };
    };
  };
  
  apps = {
    browser.firefox.enable = true;
    terminal.kitty.enable = true;
    development.git = {
      enable = true;
      userName = "Developer Name";
      userEmail = "dev@example.com";
      enableCommitTemplate = true;
    };
  };
  
  fonts.enable = true;
};
```.browser = {
  enable = true;
  firefox.enable = true;
};
```

### Privacy-Focused Firefox

```nix
userPackages.apps.browser.firefox = {
  enable = true;
  privacy = {
    enable = true;
    disableTelemetry = true;
    disablePocket = true;
    disableAccounts = true;
    dnsOverHttps = {
      enable = true;
      providerUrl = "https://dns.nextdns.io/abc123"; # Custom DNS provider
    };
  };
};
```

## Development Tools Configuration

### Basic Development Setup

```nix
userPackages.development = {
  enable = true;
  nix.enable = true;
  nodejs.enable = true;
};
```

### Comprehensive Development Environment

```nix
userPackages.development = {
  enable = true;
  nix.enable = true;
  markdown.enable = true;
  nodejs.enable = true;
  python.enable = true;
  tooling.enable = true;
  
  github = {
    enable = true;
    enableCompletions = true;
  };
};

userPackages.apps.development.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  defaultBranch = "main";
  enableCommitTemplate = true;
  enableCommitHooks = true;
};
```

## Editor Configuration

### Basic Neovim Setup

```nix
userPackages.editors = {
  enable = true;
  neovim.enable = true;
};
```

### Full-Featured Neovim IDE

```nix
userPackages.editors.neovim = {
  enable = true;
  plugins = {
    enable = true;
    lsp.enable = true;         # Language Server Protocol
    git.enable = true;         # Git integration
    markdown.enable = true;    # Markdown support
  };
};
```

## Terminal Configuration

### Basic Terminal Setup

```nix
userPackages.apps.terminal = {
  enable = true;
  kitty.enable = true;
};
```

### Customized Terminal

```nix
userPackages.apps
```