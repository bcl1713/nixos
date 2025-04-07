---
title: Configuration Options
---

# Configuration Options

This page documents all configuration options available in the NixOS Home-Manager configuration. Use this as a reference to customize your setup according to your preferences.

## Core Options

These options control basic behavior of the configuration.

### System Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `systemSettings.profile` | string | `"personal"` | The configuration profile to use |
| `userSettings.username` | string | - | Your system username |
| `userSettings.name` | string | - | Your full name |
| `userSettings.email` | string | - | Your email address |

## Window Manager

Options related to the window manager and desktop environment.

### Hyprland

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.wm.enable` | boolean | `true` | Enable window manager configurations |
| `userPackages.wm.hyprland.enable` | boolean | `true` | Enable Hyprland window manager |
| `userPackages.wm.hyprland.swaylock.enable` | boolean | `true` | Enable Swaylock for screen locking |
| `userPackages.wm.hyprland.swayidle.enable` | boolean | `true` | Enable Swayidle for automatic screen locking |
| `userPackages.wm.hyprland.swayidle.timeouts.lock` | integer | `300` | Seconds of inactivity before locking screen |
| `userPackages.wm.hyprland.swayidle.timeouts.dpms` | integer | `600` | Seconds of inactivity before turning off display |

### Waybar

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.wm.waybar.enable` | boolean | `true` | Enable Waybar status bar |

## Utilities

Options for system utilities and tools.

### System Monitoring

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.system.enable` | boolean | `true` | Enable system utilities |
| `userPackages.utilities.system.monitoring.enable` | boolean | `true` | Enable system resource monitoring |
| `userPackages.utilities.system.monitoring.topTools.enable` | boolean | `true` | Enable terminal-based monitoring tools |
| `userPackages.utilities.system.monitoring.graphical.enable` | boolean | `true` | Enable graphical monitoring tools |
| `userPackages.utilities.system.monitoring.waybar.enable` | boolean | `true` | Enable monitoring in waybar |
| `userPackages.utilities.system.monitoring.waybar.cpu.enable` | boolean | `true` | Show CPU metrics in waybar |
| `userPackages.utilities.system.monitoring.waybar.memory.enable` | boolean | `true` | Show memory metrics in waybar |
| `userPackages.utilities.system.monitoring.waybar.disk.enable` | boolean | `true` | Show disk metrics in waybar |
| `userPackages.utilities.system.monitoring.waybar.disk.mountPoint` | string | `"/"` | Mount point to monitor for disk usage |
| `userPackages.utilities.system.monitoring.waybar.temperature.enable` | boolean | `true` | Show temperature metrics in waybar |

### Disk Usage

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.diskUsage.enable` | boolean | `true` | Enable disk usage analysis tools |
| `userPackages.utilities.diskUsage.interactiveTools.enable` | boolean | `true` | Enable terminal-based disk usage tools |
| `userPackages.utilities.diskUsage.graphicalTools.enable` | boolean | `true` | Enable graphical disk usage tools |
| `userPackages.utilities.diskUsage.duplicateFinder.enable` | boolean | `true` | Enable duplicate file finder |
| `userPackages.utilities.diskUsage.cleanupTools.enable` | boolean | `true` | Enable disk cleanup utilities |

### System Updates

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.systemUpdates.enable` | boolean | `true` | Enable enhanced system update management |
| `userPackages.utilities.systemUpdates.homeManager.enable` | boolean | `true` | Enable automatic Home Manager updates |
| `userPackages.utilities.systemUpdates.homeManager.frequency.time` | string | `"04:30"` | Time to run Home Manager updates |
| `userPackages.utilities.systemUpdates.homeManager.frequency.weekday` | enum | `"weekly"` | Update frequency (daily, weekly, monthly, or specific day) |
| `userPackages.utilities.systemUpdates.system.allowReboot` | boolean | `false` | Allow reboots after system updates |
| `userPackages.utilities.systemUpdates.system.rebootWindow.lower` | string | `"01:00"` | Lower bound for reboot window |
| `userPackages.utilities.systemUpdates.system.rebootWindow.upper` | string | `"05:00"` | Upper bound for reboot window |
| `userPackages.utilities.systemUpdates.notifications.enable` | boolean | `true` | Enable update notifications |
| `userPackages.utilities.systemUpdates.notifications.beforeUpdate` | boolean | `true` | Notify before starting updates |
| `userPackages.utilities.systemUpdates.notifications.afterUpdate` | boolean | `true` | Notify when updates complete |
| `userPackages.utilities.systemUpdates.maintenance.garbageCollection.enable` | boolean | `true` | Enable automatic garbage collection |
| `userPackages.utilities.systemUpdates.maintenance.garbageCollection.maxAge` | integer | `30` | Maximum age of generations to keep (days) |
| `userPackages.utilities.systemUpdates.maintenance.garbageCollection.frequency` | enum | `"weekly"` | How often to run garbage collection |
| `userPackages.utilities.systemUpdates.maintenance.optimizeStore` | boolean | `true` | Optimize Nix store after garbage collection |

### Screenshots and Screen Recording

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.screenshot.enable` | boolean | `true` | Enable screenshot tools |
| `userPackages.utilities.screenshot.screenKeybinding` | string | `", Print"` | Keybinding for full screen capture |
| `userPackages.utilities.screenshot.areaKeybinding` | string | `"ALT, Print"` | Keybinding for area capture |
| `userPackages.utilities.screenshot.windowKeybinding` | string | `"CTRL, Print"` | Keybinding for window capture |
| `userPackages.utilities.screenshot.screenAnnotateKeybinding` | string | `"SHIFT, Print"` | Keybinding for screen capture with annotation |
| `userPackages.utilities.screenshot.areaAnnotateKeybinding` | string | `"ALT SHIFT, Print"` | Keybinding for area capture with annotation |
| `userPackages.utilities.screenshot.windowAnnotateKeybinding` | string | `"CTRL SHIFT, Print"` | Keybinding for window capture with annotation |
| `userPackages.utilities.screenRecording.enable` | boolean | `true` | Enable screen recording |
| `userPackages.utilities.screenRecording.keybinding` | string | `"SUPER SHIFT, R"` | Keybinding to toggle recording |
| `userPackages.utilities.screenRecording.areaKeybinding` | string | `"SUPER SHIFT ALT, R"` | Keybinding to record selected area |
| `userPackages.utilities.screenRecording.windowKeybinding` | string | `"SUPER CTRL, R"` | Keybinding to record active window |
| `userPackages.utilities.screenRecording.audioSupport` | boolean | `true` | Enable audio capture in recordings |

### Clipboard Management

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.clipboard.enable` | boolean | `true` | Enable clipboard management |
| `userPackages.utilities.clipboard.historySize` | integer | `15` | Number of clipboard items to store |
| `userPackages.utilities.clipboard.startInBackground` | boolean | `true` | Start clipboard manager in background |
| `userPackages.utilities.clipboard.mimeTypeConfig` | boolean | `true` | Enable MIME type handling for clipboard |

### Power Management

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.powerManagement.enable` | boolean | `true` | Enable enhanced power management |
| `userPackages.utilities.powerManagement.defaultProfile` | enum | `"balanced"` | Default power profile |
| `userPackages.utilities.powerManagement.keybinding` | string | `"SUPER, F7"` | Keybinding to cycle between profiles |
| `userPackages.utilities.powerManagement.indicator.enable` | boolean | `true` | Show power profile indicator in waybar |

### Application Launchers

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.rofi.enable` | boolean | `false` | Enable Rofi application launcher |
| `userPackages.utilities.wofi.enable` | boolean | `true` | Enable Wofi application launcher |
| `userPackages.utilities.wofi.terminal` | string | `"kitty"` | Terminal for terminal commands |
| `userPackages.utilities.wofi.theme.enable` | boolean | `true` | Enable Catppuccin theming for Wofi |
| `userPackages.utilities.wofi.modes.drun.enable` | boolean | `true` | Enable application launcher mode |
| `userPackages.utilities.wofi.modes.window.enable` | boolean | `true` | Enable window switcher mode |
| `userPackages.utilities.wofi.modes.emoji.enable` | boolean | `true` | Enable emoji picker mode |

### Password Management

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.utilities.bitwarden.enable` | boolean | `true` | Enable Bitwarden password manager |
| `userPackages.utilities.bitwarden.desktop.enable` | boolean | `true` | Enable Bitwarden desktop client |
| `userPackages.utilities.bitwarden.desktop.autostart` | boolean | `true` | Autostart Bitwarden desktop client |
| `userPackages.utilities.bitwarden.cli.enable` | boolean | `true` | Enable Bitwarden CLI |
| `userPackages.utilities.bitwarden.cli.addShellAliases` | boolean | `true` | Add helpful shell aliases for Bitwarden |

## Applications

Options for applications and their configurations.

### Browser

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.apps.browser.enable` | boolean | `true` | Enable browser applications |
| `userPackages.apps.browser.firefox.enable` | boolean | `true` | Enable Firefox browser |
| `userPackages.apps.browser.firefox.privacy.enable` | boolean | `true` | Enable privacy enhancements |
| `userPackages.apps.browser.firefox.privacy.disableTelemetry` | boolean | `true` | Disable telemetry in Firefox |
| `userPackages.apps.browser.firefox.privacy.disablePocket` | boolean | `true` | Disable Pocket in Firefox |
| `userPackages.apps.browser.firefox.privacy.disableAccounts` | boolean | `true` | Disable Firefox accounts |
| `userPackages.apps.browser.firefox.privacy.dnsOverHttps.enable` | boolean | `true` | Enable DNS over HTTPS |
| `userPackages.apps.browser.firefox.privacy.dnsOverHttps.providerUrl` | string | `"https://dns.quad9.net/dns-query"` | Provider URL for DNS over HTTPS |

### Development

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.apps.development.enable` | boolean | `true` | Enable development applications |
| `userPackages.apps.development.git.enable` | boolean | `true` | Enable Git with configuration |
| `userPackages.apps.development.git.userName` | string | `"Brian Lucas"` | Git user name |
| `userPackages.apps.development.git.userEmail` | string | `""` | Git user email |
| `userPackages.apps.development.git.defaultBranch` | string | `"main"` | Default branch for new repositories |
| `userPackages.apps.development.git.enableCommitTemplate` | boolean | `true` | Enable commit message template |
| `userPackages.apps.development.git.enableCommitHooks` | boolean | `true` | Enable commit message hooks |

### Terminal

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.apps.terminal.enable` | boolean | `true` | Enable terminal applications |
| `userPackages.apps.terminal.kitty.enable` | boolean | `true` | Enable Kitty terminal |
| `userPackages.apps.terminal.kitty.font.family` | string | `"FiraCode Nerd Font Mono"` | Font family for Kitty |
| `userPackages.apps.terminal.kitty.font.size` | integer | `null` | Font size for Kitty (null uses default) |
| `userPackages.apps.terminal.kitty.theme` | string | `"Catppuccin-Mocha"` | Theme for Kitty terminal |

### Productivity

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.apps.productivity.enable` | boolean | `true` | Enable productivity applications |
| `userPackages.apps.productivity.nextcloud.enable` | boolean | `true` | Enable Nextcloud client |
| `userPackages.apps.productivity.nextcloud.startInBackground` | boolean | `true` | Start Nextcloud client in background |

### Creative

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.apps.creative.enable` | boolean | `true` | Enable creative applications |
| `userPackages.apps.creative.prusaSlicer.enable` | boolean | `true` | Enable Prusa Slicer |

## Development Environment

Options for development tools and environments.

### Development Tools

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.development.enable` | boolean | `true` | Enable development tools |
| `userPackages.development.nix.enable` | boolean | `true` | Enable Nix development tools |
| `userPackages.development.markdown.enable` | boolean | `true` | Enable Markdown tools |
| `userPackages.development.nodejs.enable` | boolean | `true` | Enable Node.js development tools |
| `userPackages.development.python.enable` | boolean | `true` | Enable Python development tools |
| `userPackages.development.tooling.enable` | boolean | `true` | Enable general development tooling |
| `userPackages.development.github.enable` | boolean | `true` | Enable GitHub CLI and related tools |
| `userPackages.development.github.enableCompletions` | boolean | `true` | Enable GitHub shell completions |

## Editors

Options for text editors and their configurations.

### Neovim

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.editors.enable` | boolean | `true` | Enable editor configurations |
| `userPackages.editors.neovim.enable` | boolean | `true` | Enable Neovim editor |
| `userPackages.editors.neovim.plugins.enable` | boolean | `true` | Enable Neovim plugins |
| `userPackages.editors.neovim.plugins.lsp.enable` | boolean | `true` | Enable LSP support |
| `userPackages.editors.neovim.plugins.git.enable` | boolean | `true` | Enable Git integration |
| `userPackages.editors.neovim.plugins.markdown.enable` | boolean | `true` | Enable Markdown support |

## Fonts

Options for fonts and typography.

### Font Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.fonts.enable` | boolean | `true` | Enable custom fonts |
| `userPackages.fonts.nerdFonts.enable` | boolean | `true` | Enable Nerd Fonts |
| `userPackages.fonts.nerdFonts.firaCode.enable` | boolean | `true` | Enable FiraCode Nerd Font |
| `userPackages.fonts.systemFonts.enable` | boolean | `true` | Enable system fonts |

## Media

Options for media applications and tools.

### Media Tools

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.media.enable` | boolean | `true` | Enable media tools |
| `userPackages.media.audio.enable` | boolean | `true` | Enable audio tools |
| `userPackages.media.video.enable` | boolean | `true` | Enable video tools |
| `userPackages.media.image.enable` | boolean | `true` | Enable image tools |

## Scripts

Options for custom scripts and utilities.

### Script Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `userPackages.scripts.enable` | boolean | `true` | Enable custom scripts |
| `userPackages.scripts.wifi.enable` | boolean | `true` | Enable WiFi menu script |
| `userPackages.scripts.battery.enable` | boolean | `true` | Enable battery warning script |
| `userPackages.scripts.battery.lowThreshold` | integer | `15` | Battery percentage for low warning |
| `userPackages.scripts.battery.criticalThreshold` | integer | `5` | Battery percentage for critical warning |
| `userPackages.scripts.directoryCombiner.enable` | boolean | `true` | Enable directory combiner tool |
| `userPackages.scripts.outputGenerator.enable` | boolean | `true` | Enable output file generator script |

## Examples

### Minimal Configuration

```nix
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

### Development-Focused Configuration

```nix
userPackages = {
  development = {
    enable = true;
    nix.enable = true;
    nodejs.enable = true;
    python.enable = true;
    tooling.enable = true;
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
  
  apps = {
    development = {
      git = {
        enable = true;
        userName = "Your Name";
        userEmail = "your.email@example.com";
      };
    };
  };
};
```

### Media Workstation Configuration

```nix
userPackages = {
  media = {
    enable = true;
    audio.enable = true;
    video.enable = true;
    image.enable = true;
  };
  
  apps = {
    creative.enable = true;
  };
  
  utilities = {
    screenRecording.enable = true;
    screenshot.enable = true;
  };
};
```
