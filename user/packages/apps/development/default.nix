# user/packages/apps/development/default.nix

{ config, lib, ... }:

with lib;

let cfg = config.userPackages.apps.development;
in {
  imports = [
    ./git.nix
    # Add other development tools here later
  ];

  options.userPackages.apps.development = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable development applications";
    };
  };

  config = mkIf cfg.enable {
    # Global development configurations can go here if needed
  };
}
