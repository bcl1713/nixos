# user/wm/default.nix

{ config, pkgs, ... }:

{
  imports = [
    ./hyprland/hyprland.nix
  ];
}
