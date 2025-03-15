# user/wm/hyprland/hyprland.nix

{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
  };

  # Install packages related to Hyprland
  home.packages = with pkgs; [
    wofi
    waybar
    hyprpaper
    swaylock
    swayidle
    wl-clipboard
    grim
    slurp
  ];

  # Configure Hyprland using separate configuration files
  home.file."${config.xdg.configHome}/hypr" = {
    source = ./.;
  };

  home.file."${config.xdg.configHome}/waybar" = {
    source = ./waybar;
  };
}
