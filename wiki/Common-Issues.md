---
title: Common Issues
---

# Common Issues

This page addresses frequently encountered issues and their solutions.

## Installation Issues

### Error: Failed to Commit Transaction

**Symptom**: Error when running `nixos-rebuild switch` about failed transaction.

**Solution**: 
1. Make sure you have internet connectivity
2. Try updating the channel: `sudo nix-channel --update`
3. Clear the Nix store: `sudo nix-collect-garbage -d`
4. Try again with: `sudo nixos-rebuild switch --option substituters "https://cache.nixos.org/"`

### Error: Cannot Find Module

**Symptom**: Error message like `error: cannot find module 'user/packages/...'`.

**Solution**:
1. Check if the path is correct in your imports
2. Ensure the file exists at the specified location
3. Verify case sensitivity in file paths
4. Check for syntax errors in the imported module

### Home Manager Module Not Found

**Symptom**: Error about home-manager module not being found.

**Solution**:
1. Make sure home-manager is installed: `nix-env -iA nixos.home-manager`
2. Add the channel if needed: `nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager`
3. Update channels: `nix-channel --update`
4. Import properly in configuration: `imports = [ <home-manager/nixos> ];`

## Hyprland Issues

### Hyprland Fails to Start

**Symptom**: Black screen or immediate crash when starting Hyprland.

**Solution**:
1. Check for errors in `~/.local/share/hyprland/hyprland.log`
2. Ensure your GPU supports Wayland: `lspci | grep -i 'vga\\|3d'`
3. Verify the correct drivers are installed for your GPU
4. Try a minimal configuration: `Hyprland -c /dev/null`
5. Check if the required services are running: `systemctl --user status hyprland-session.target`

### Screen Tearing or Graphical Glitches

**Symptom**: Visual artifacts or screen tearing during use.

**Solution**:
1. Configure VSync in your Hyprland configuration:
   ```nix
   general {
     allow_tearing = false;
   }
   ```
2. Check your GPU driver settings
3. Try disabling animations to see if the issue persists:
   ```nix
   animations {
     enabled = false;
   }
   ```

### Keybindings Not Working

**Symptom**: Configured keybindings have no effect.

**Solution**:
1. Check for conflicting keybindings with `hyprctl binds`
2. Verify syntax in your config file
3. Restart Hyprland completely
4. Ensure the correct modifier keys are being used
5. Check if the command being executed exists and is in your PATH

## Theme and Appearance Issues

### Fonts Looking Incorrect

**Symptom**: Fonts are missing, broken, or showing as squares/placeholders.

**Solution**:
1. Make sure the font is installed:
   ```nix
   userPackages.fonts.nerdFonts.enable = true;
   ```
2. Rebuild your font cache: `fc-cache -fv`
3. Check if the font is being found: `fc-list | grep "FontName"`
4. Ensure applications are configured to use the font correctly

### Wrong Theme Being Applied

**Symptom**: Applications don't respect the selected theme.

**Solution**:
1. Check if the theme is installed correctly
2. Verify the theme is properly configured in the relevant applications
3. Restart the applications or session
4. For GTK apps, check `~/.config/gtk-3.0/settings.ini`
5. For Qt apps, check if `qt5ct` or `qt6ct` is configured properly

## Update Issues

### Error: flake.nix has changed while we were evaluating it

**Symptom**: Error message about flake changes during evaluation.

**Solution**:
1. This usually happens when files are modified during the build
2. Avoid running other commands that modify your configuration during build
3. Try again without any other file modifications in progress
4. If persistent, clean the build directory: `rm -rf ./.direnv/`

### Home Manager Update Fails

**Symptom**: `home-manager switch` fails with various errors.

**Solution**:
1. Check the exact error message for specific issues
2. Ensure your home-manager version is compatible with nixpkgs version
3. Try updating channels first: `nix-channel --update`
4. Run with more verbose output: `home-manager switch -v`
5. Check for syntax errors in your configuration

## Service Issues

### Service Fails to Start

**Symptom**: System or user service doesn't start properly.

**Solution**:
1. Check service status: `systemctl --user status service-name`
2. Look at logs: `journalctl --user -u service-name -e`
3. Verify service configuration
4. Check if required dependencies are installed
5. Try restarting the service: `systemctl --user restart service-name`

### Application Autostart Not Working

**Symptom**: Applications configured to autostart don't launch.

**Solution**:
1. Check if the autostart entry is correct in your configuration
2. Verify the application binary exists in your PATH
3. Check logs: `journalctl --user -b`
4. Try running the application manually to see if it works
5. Ensure the appropriate target is enabled: `systemctl --user status hyprland-session.target`

## Hardware Issues

### Audio Not Working

**Symptom**: No sound from applications or system.

**Solution**:
1. Check if PipeWire is running: `systemctl --user status pipewire`
2. Check audio devices: `pactl list sinks`
3. Check volume levels: `pactl list sinks | grep Volume`
4. Try restarting the audio subsystem: `systemctl --user restart pipewire.service`
5. Ensure the correct audio device is selected in application settings

### Battery Drain Too Fast

**Symptom**: Battery drains much faster than expected.

**Solution**:
1. Check for power-hungry processes: `htop`
2. Configure TLP for better power management:
   ```nix
   services.tlp = {
     enable = true;
     settings = {
       CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
     };
   };
   ```
3. Check if the power-management service is running: `systemctl status tlp.service`
4. Consider adding `poweralertd` for low battery notifications

## Debugging Techniques

### Getting More Information

1. Enable verbose logging: add `-v` flag to commands
2. Check system journals: `journalctl -b`
3. Check user journals: `journalctl --user -b`
4. Review application-specific logs in `~/.local/share/` or `~/.cache/`

### Testing Configuration Changes

1. Use `home-manager build` instead of `switch` to check for errors
2. Test changes in isolation when possible
3. Use `nix-shell` to test package installations without changing system state
4. Create a separate user profile for testing major changes

### Getting Help

If you're still stuck after trying these solutions:

1. Check the [NixOS Discourse](https://discourse.nixos.org/)
2. Ask in the NixOS Matrix/IRC channels
3. Search or ask on the [NixOS subreddit](https://www.reddit.com/r/NixOS/)
4. Check for similar issues in the GitHub repository
5. Provide detailed information when asking for help: logs, configuration snippets, and exact error messages
