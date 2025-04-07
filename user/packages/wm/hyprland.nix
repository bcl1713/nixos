# user/packages/wm/hyprland.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.wm.hyprland;
in {
  # Imports must be at the top level of the module
  imports = [ ./hyprland/hyprland.nix ./hyprland/swayidle.nix ];

  config = mkIf cfg.enable {

    # Configure swayidle if enabled
    services.swayidle = mkIf cfg.swayidle.enable {
      enable = true;
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

    # Configure the lock-screen command
    home.packages = mkIf cfg.swaylock.enable [
      (pkgs.writeShellScriptBin "lock-screen" ''
        ${pkgs.swaylock}/bin/swaylock -f
      '')
    ];
  };
}
