# user/packages/utilities/clipboard.nix

{ config, lib, pkgs, ... }:

with lib;

let 
  cfg = config.userPackages.utilities.clipboard;
in {
  options.userPackages.utilities.clipboard = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable clipboard management";
    };

    historySize = mkOption {
      type = types.int;
      default = 15;
      description = "Number of clipboard items to store in history";
    };

    startInBackground = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start the clipboard manager in background";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      clipman
    ];

    # Create the systemd user service for clipman
    systemd.user.services.clipman = {
      Unit = {
        Description = "Clipboard manager service";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.clipman}/bin/clipman --histsize=${toString cfg.historySize} store --no-persist";
        Restart = "on-failure";
        RestartSec = 5;
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Configure keybinding in Hyprland if enabled
    wayland.windowManager.hyprland.settings = mkIf config.wayland.windowManager.hyprland.enable {
      bind = [
        # Add clipboard history keybinding - using SUPER+SHIFT+V 
        "SUPER SHIFT, V, exec, ${pkgs.clipman}/bin/clipman pick --tool=wofi"
      ];
    };

    # Ensure wl-copy is used for capturing clipboard
    home.sessionVariables = {
      CM_SELECTIONS = "clipboard";
      CM_MAX_CLIPS = toString cfg.historySize;
    };
    
    # Make sure wl-clipboard captures clipboard content automatically
    systemd.user.services.wl-clipboard-watch = {
      Unit = {
        Description = "Watch clipboard for changes";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.clipman}/bin/clipman store --max-items=${toString cfg.historySize}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
