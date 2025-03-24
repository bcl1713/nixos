# user/packages/scripts/default.nix

{ config, lib, ... }:

with lib;

let 
  cfg = config.userPackages.scripts;
in {
  imports = [
    ./wifi.nix
    ./battery.nix
    ./tools.nix
  ];

  options.userPackages.scripts = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable custom scripts";
    };
    
    wifi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable WiFi menu script";
      };
    };
    
    battery = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable battery warning script";
      };
      
      lowThreshold = mkOption {
        type = types.int;
        default = 15;
        description = "Battery percentage to trigger low battery warning";
      };
      
      criticalThreshold = mkOption {
        type = types.int;
        default = 5;
        description = "Battery percentage to trigger critical battery warning";
      };
    };
    
    tools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable utility tools";
      };
      
      directoryCombiner = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable directory combiner tool";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Global configuration for scripts goes here if needed
  };
}
