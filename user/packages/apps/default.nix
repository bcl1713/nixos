# user/packages/apps/default.nix

{ config, lib, ... }:

with lib;

let cfg = config.userPackages.apps;
in {
  imports = [ ./browser ./development ./terminal ./productivity ./creative ];

  options.userPackages.apps = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable application packages";
    };
  };

  config = mkIf cfg.enable {
    # Global application configurations can go here if needed
  };
}
