# user/packages/wm/default.nix

{ config, lib, ... }:

with lib;

let cfg = config.userPackages.wm;
in {
  imports = [ ./hyprland.nix ./waybar.nix ];

  options.userPackages.wm = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable window manager configurations";
    };

    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Hyprland window manager";
      };

      swaylock = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable Swaylock for screen locking";
        };
      };

      swayidle = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description =
            "Whether to enable Swayidle for automatic screen locking";
        };

        timeouts = {
          lock = mkOption {
            type = types.int;
            default = 300;
            description = "Seconds of inactivity before locking the screen";
          };

          dpms = mkOption {
            type = types.int;
            default = 600;
            description =
              "Seconds of inactivity before turning off the display";
          };
        };
      };
    };

  };

  config = mkIf cfg.enable {
    # Global configurations for window managers
  };
}
