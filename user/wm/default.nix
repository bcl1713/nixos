# user/wm/default.nix

{ ... }:

{
  imports = [
    ./hyprland/hyprland.nix
    ./hyprland/swayidle.nix
  ];
}
