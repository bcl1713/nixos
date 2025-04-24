# wiki/examples/keybinding-cheatsheet-config.nix
#
# Example configuration for the keybinding cheatsheet feature

# In your home.nix configuration:
userPackages = {
  # Enable scripts module
  scripts = {
    enable = true;
    
    # Configure keybinding cheatsheet
    keybindingCheatsheet = {
      enable = true;
      
      # Customize the keyboard shortcut to display the cheatsheet
      keybinding = "SUPER, slash";
      
      # Change default display format (terminal, wofi, rofi, markdown)
      defaultFormat = "wofi";
      
      # Manually control which features to include
      # (these are auto-detected by default)
      includeScreenRecording = true;
      includeClipboard = true;
      includeBluetooth = true;
      includeTailscale = true;
      includePowerProfile = true;
    };
  };
  
  # Ensure other related features are enabled
  utilities = {
    enable = true;
    
    # These features will be detected and included in the cheatsheet
    wofi.enable = true;
    screenRecording.enable = true;
    clipboard.enable = true;
    bluetooth = {
      enable = true;
      waybar.enable = true;
    };
    tailscale = {
      enable = true;
      waybar.enable = true;
    };
    powerManagement = {
      enable = true;
      indicator.enable = true;
    };
  };
  
  # Ensure Hyprland and Waybar are enabled for their keybindings
  wm = {
    enable = true;
    hyprland.enable = true;
    waybar.enable = true;
  };
};
