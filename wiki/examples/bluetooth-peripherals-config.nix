# wiki/examples/bluetooth-peripherals-config.nix
#
# Example configuration for Bluetooth and peripherals management

# In your home.nix configuration:
userPackages = {
  # Enable utilities
  utilities = {
    enable = true;
    
    # Enable Bluetooth management
    bluetooth = {
      enable = true;
      autostart.enable = true;
      audio.enable = true;
      gui = {
        enable = true;
        blueman.enable = true;
      };
      waybar.enable = true;
    };
    
    # Enable peripherals management
    peripherals = {
      enable = true;
      
      # Enable Corsair device support for Harpoon mouse
      corsair = {
        enable = true;
        autostart = true;
      };
      
      # Optionally enable other device brands
      logitech.enable = false;
      razer.enable = false;
    };
  };
  
  # Ensure Waybar is enabled for status indicators
  wm = {
    enable = true;
    waybar.enable = true;
  };
};

# For system-level Bluetooth support, in your configuration.nix:
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };
};

# For audio integration in configuration.nix:
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  # Enable Bluetooth codec support
  media-session.config.bluez-monitor.rules = [
    {
      # Matches all cards
      matches = [ { "device.name" = "~bluez_card.*"; } ];
      actions = {
        "update-props" = {
          "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          "bluez5.msbc-support" = true;
          "bluez5.sbc-xq-support" = true;
        };
      };
    }
  ];
};
