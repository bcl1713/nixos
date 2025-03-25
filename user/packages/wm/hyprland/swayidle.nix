# user/wm/hyprland/swayidle.nix
{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { 
        timeout = 600; 
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };

  home.packages = with pkgs; [
    (writeShellScriptBin "lock-screen" ''
      ${pkgs.swaylock}/bin/swaylock -f
    '')
  ];
}
