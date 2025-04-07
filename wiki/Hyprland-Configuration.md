---
title: Hyprland Configuration
---

# Hyprland Configuration

This guide provides detailed information about the Hyprland window manager configuration included in this setup.

## Overview

[Hyprland](https://hyprland.org/) is a dynamic tiling Wayland compositor that offers a modern, customizable desktop experience. This configuration provides a carefully tuned Hyprland setup with:

- Catppuccin Mocha theming
- Optimized window management
- Hardware acceleration support
- Integration with other system components

## Configuration Structure

The Hyprland configuration is structured as follows:

```
user/packages/wm/
├── default.nix            # Main WM module
├── hyprland.nix           # Hyprland-specific module
├── hyprland/              # Hyprland resources
│   ├── background.png     # Default wallpaper
│   ├── hyprland.nix       # Core Hyprland configuration
│   ├── hyprpaper.conf     # Wallpaper configuration
│   ├── swaylock/          # Screen locking configuration
│   └── swayidle.nix       # Idle management configuration
└── waybar.nix             # Status bar configuration
```

## Basic Settings

The core Hyprland settings can be found in `user/packages/wm/hyprland/hyprland.nix`. This includes:

- Monitor configuration
- Input device settings
- Appearance and animations
- Default applications
- Keybindings

### Enabling/Disabling Features

You can toggle Hyprland features in your `home.nix`:

```nix
userPackages.wm = {
  enable = true;
  hyprland = {
    enable = true;
    swaylock.enable = true;    # Screen locking
    swayidle.enable = true;    # Idle management
    swayidle.timeouts = {
      lock = 300;              # Seconds before locking screen
      dpms = 600;              # Seconds before turning off display
    };
  };
  waybar.enable = true;        # Status bar
};
```

## Customizing Hyprland

### Modifying Default Applications

The default applications can be changed in the Hyprland configuration:

```nix
# In user/packages/wm/hyprland/hyprland.nix
settings = {
  "$terminal" = "kitty";     # Change to your preferred terminal
  "$fileManager" = "nautilus"; # Change to your preferred file manager
  "$browser" = "firefox";    # Change to your preferred browser
};
```

### Changing Key Bindings

The keybindings are defined in the `bind` section:

```nix
# In user/packages/wm/hyprland/hyprland.nix
"$mainMod" = "SUPER";   # Windows/Command key

bind = [
  "$mainMod, return, exec, $terminal"
  "$mainMod, C, killactive,"
  # Add your custom bindings here
  "$mainMod, F, exec, $browser"
];
```

Common modifications include:

- Changing the mod key (e.g., to ALT)
- Adding application shortcuts
- Customizing workspace management
- Adding multimedia controls

### Appearance Settings

The appearance settings control the visual style:

```nix
# In user/packages/wm/hyprland/hyprland.nix
general = {
  border_size = 4;
  gaps_in = 8;        # Inner gaps between windows
  gaps_out = 16;      # Outer gaps around screen edges
};

decoration = {
  rounding = 4;        # Window corner rounding
  blur.enabled = true;
  active_opacity = 1.0;
  inactive_opacity = 0.8;
};
```

### Animation Settings

Animations can be customized for a smoother experience:

```nix
# In user/packages/wm/hyprland/hyprland.nix
animations = {
  enabled = true;   # Set to false to disable all animations
  
  # Custom animation curves
  bezier = [
    "easeOutQuint,0.23,1,0.32,1"
    # Add your custom bezier curves here
  ];
  
  # Animation definitions
  animation = [
    "windows, 1, 4.79, easeOutQuint"
    # Customize window animations
  ];
};
```

## Advanced Configuration

### Multiple Monitors

For multiple monitors, update the monitor configuration:

```nix
# In user/packages/wm/hyprland/hyprland.nix
monitor = [
  "DP-1, 2560x1440@144, 0x0, 1"    # Primary monitor
  "HDMI-A-1, 1920x1080@60, 2560x0, 1"  # Secondary monitor
];
```

### GPU-Specific Settings

For NVIDIA GPUs, add special environment variables:

```nix
# In user/packages/wm/hyprland/hyprland.nix
env = [
  "XCURSOR_SIZE,24"
  "HYPRCURSOR_SIZE,24"
  "WLR_NO_HARDWARE_CURSORS,1"          # For NVIDIA 
  "__GL_GSYNC_ALLOWED,0"               # Disable G-SYNC
  "__GL_VRR_ALLOWED,0"                 # Disable VRR
  "WLR_DRM_NO_ATOMIC,1"                # For older GPUs
];
```

### Custom Rules for Applications

Window rules allow you to control how specific applications behave:

```nix
# In user/packages/wm/hyprland/hyprland.nix
windowrulev2 = [
  "float, class:^(pavucontrol)$"           # Make pavucontrol float
  "workspace 2, class:^(firefox)$"         # Open Firefox on workspace 2
  "size 800 600, class:^(kitty)$, title:^(float)$" # Size for floating terminal
];
```

### XWayland Configuration

XWayland allows running X11 applications:

```nix
# In user/packages/wm/hyprland/hyprland.nix
xwayland = {
  force_zero_scaling = true;  # Helps with scaling issues for legacy apps
};
```

## Integrations

### Swaylock (Screen Locking)

Swaylock is configured for secure screen locking with Catppuccin theming:

```nix
# In user/packages/wm/hyprland/swaylock/config
indicator-radius=145
indicator-thickness=15
ring-color=181825
ring-ver-color=89b4fa
inside-color=1e1e2e
```

You can lock the screen manually with the keybinding:

```
SUPER + X
```

### Swayidle (Idle Management)

Swayidle handles automatic screen locking and display power management:

```nix
# In user/packages/wm/hyprland/swayidle.nix
services.swayidle = {
  timeouts = [
    {
      timeout = cfg.swayidle.timeouts.lock;
      command = "${pkgs.swaylock}/bin/swaylock -f";
    }
    {
      timeout = cfg.swayidle.timeouts.dpms;
      command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
      resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
    }
  ];
};
```

### Waybar (Status Bar)

Waybar provides a customizable status bar with:

- Workspace indicators
- System information
- Network status
- Battery level
- Clock/calendar
- Custom modules

You can customize Waybar in `user/packages/wm/waybar.nix`:

```nix
programs.waybar.settings.mainBar = {
  modules-left = ["hyprland/workspaces"];
  modules-center = ["hyprland/window"];
  modules-right = ["network", "pulseaudio", "battery", "clock"];
};
```

## Performance Tuning

To optimize Hyprland performance:

1. **Animations**: Disable or reduce animations on lower-end hardware:
   ```nix
   animations.enabled = false;
   ```

2. **Transparency**: Reduce or eliminate transparency effects:
   ```nix
   decoration = {
     active_opacity = 1.0;
     inactive_opacity = 1.0;
     blur.enabled = false;
   };
   ```

3. **Disable VSync** for more responsive feel (may cause tearing):
   ```nix
   misc = {
     vfr = true;  # Variable refresh rate
   };
   ```

## Troubleshooting

### Common Issues

1. **Black screen on startup**:
   - Check logs: `cat ~/.local/share/hyprland/hyprland.log`
   - Verify GPU drivers are installed correctly
   - Try starting with minimal config: `Hyprland -c /dev/null`

2. **Applications not launching**:
   - Check if the application binary exists: `which app-name`
   - Try running from terminal to see error messages
   - Verify environment variables in `hyprland.nix`

3. **Screen tearing**:
   - Enable VSync: `misc.vfr = false;`
   - Check GPU driver settings
   - Try different rendering options

4. **Input issues**:
   - Check input configuration in `hyprland.nix`
   - Verify input devices are detected with `libinput list-devices`

### Debug Mode

To launch Hyprland in debug mode:

```bash
Hyprland -d
```

### Viewing Logs

To check Hyprland logs:

```bash
cat ~/.local/share/hyprland/hyprland.log
```

## Additional Resources

- [Official Hyprland Documentation](https://wiki.hyprland.org/)
- [Hyprland GitHub Repository](https://github.com/hyprwm/Hyprland)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Waybar Configuration Examples](https://github.com/Alexays/Waybar/wiki/Examples)
