# user/packages/apps/productivity/default.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.apps.productivity;
in {
  options.userPackages.apps.productivity = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable productivity applications";
    };

    nextcloud = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Nextcloud client";
      };

      startInBackground = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to start Nextcloud client in background";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.nextcloud.enable {
      services.nextcloud-client = {
        enable = true;
        startInBackground = cfg.nextcloud.startInBackground;
      };

      # Override the systemd service configuration
      systemd.user.services.nextcloud-client = {
        Unit = {
          After = lib.mkForce [ "graphical-session.target" "network.target" ];
          Requires = lib.mkForce [ "graphical-session.target" ];
          PartOf = lib.mkForce [ "graphical-session.target" ];
          Description = lib.mkForce "Nextcloud desktop client";
        };
        Install = { WantedBy = lib.mkForce [ "graphical-session.target" ]; };
        Service = {
          # Add a short delay to ensure everything is ready
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      home.packages = with pkgs; [ nextcloud-client ];
    })
  ]);
}
