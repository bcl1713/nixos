# user/packages/apps/creative/default.nix
#
# This module provides creative applications with sensible defaults.
# Prusa Slicer is configured for 3D printing.

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.apps.creative;
in {
  options.userPackages.apps.creative = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable creative applications";
    };

    prusaSlicer = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Prusa Slicer";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.prusaSlicer.enable {
      home.packages = with pkgs; [ prusa-slicer ];
    })
  ]);
}
