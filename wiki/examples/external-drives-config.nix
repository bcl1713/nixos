# wiki/examples/external-drives-config.nix
#
# Example configuration for external drive management

# In your home.nix configuration:
userPackages.utilities = {
  enable = true;
  
  # Enable external drive management
  externalDrives = {
    enable = true;
    
    # Automatically mount drives when connected
    autoMount.enable = true;
    
    # Enable graphical tools for drive management
    gui.enable = true;
    
    # Show notifications for drive events
    notifications.enable = true;
    
    # Install terminal utilities for advanced operations
    terminal.enable = true;
  };
  
  # Related utilities that work well with external drives
  files.enable = true;   # Basic file management utilities
  wayland.enable = true; # Wayland clipboard support for file operations
};

# For system-level drive support, in your configuration.nix:
services.udisks2 = {
  enable = true;
  mountOnMedia = true;  # Mount drives in /media instead of /run/media
};

# Add your user to the plugdev group for device access
users.users.yourusername.extraGroups = [ "plugdev" ];

# Enable filesystem support for common external drive formats
boot.supportedFilesystems = [
  "ntfs"
  "exfat"
  "ext4"
  "btrfs"
  "xfs"
];
