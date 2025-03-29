# user/packages/utilities/default.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities;
in {
  imports = [
    ./clipboard.nix
    ./rofi.nix
    ./wofi.nix
    ./screen-recording.nix
    ./screenshot.nix
    ./power-management.nix
    ./bitwarden.nix
  ];

  options.userPackages.utilities = {
    enable = mkEnableOption "Enable utility tools";

    system = { enable = mkEnableOption "Enable system monitoring tools"; };

    files = { enable = mkEnableOption "Enable file management tools"; };

    wayland = { enable = mkEnableOption "Enable Wayland-specific utilities"; };

  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.system.enable) {
      home.packages = with pkgs; [ htop btop brightnessctl ];
    })

    (mkIf (cfg.enable && cfg.files.enable) {
      home.packages = with pkgs; [ unzip zip file tree ];
    })

    (mkIf (cfg.enable && cfg.wayland.enable) {
      home.packages = with pkgs; [ wl-clipboard xdg-utils ];
    })
  ];
}
