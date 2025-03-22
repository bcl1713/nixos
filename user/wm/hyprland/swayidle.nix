# user/wm/hyprland/swayidle.nix
{ pkgs, config, ... }:

{
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { 
        timeout = 600; 
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctls dispatch dpms on";
      }
    ];
  };

  home.packages = with pkgs; [
    (writeShellScriptBin "lock-screen" ''
      ${pkgs.swaylock}/bin/swaylock -f
    '')
  ];
}
