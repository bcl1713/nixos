# user/packages/system/default.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.system;
in {
  options.userPackages.system = {
    enable = mkEnableOption "Enable system utilities";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ vim wget git gnome-keyring libsecret ];
  };
}
