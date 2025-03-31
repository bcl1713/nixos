{ config, lib, ... }:
with lib;
let cfg = config.userPackages.security;
in {
  imports = [ ./secrets.nix ];
  options.userPackages.sercurity = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable security packages";
    };
  };
  config = mkIf cfg.enable {
    # Global security configurations can go here if needed
  };
}
