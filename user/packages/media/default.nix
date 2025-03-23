# user/packages/media/default.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.media;
in {
  options.userPackages.media = {
    enable = mkEnableOption "Enable media tools";

    audio = { enable = mkEnableOption "Enable audio tools"; };

    video = { enable = mkEnableOption "Enable video tools"; };

    image = { enable = mkEnableOption "Enable image tools"; };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.audio.enable) {
      home.packages = with pkgs; [
        pavucontrol
        playerctl
        spotify # Optional
      ];
    })

    (mkIf (cfg.enable && cfg.video.enable) {
      home.packages = with pkgs; [ mpv ffmpeg ];
    })

    (mkIf (cfg.enable && cfg.image.enable) {
      home.packages = with pkgs; [
        imv # Image viewer
        gimp # Optional
      ];
    })
  ];
}
