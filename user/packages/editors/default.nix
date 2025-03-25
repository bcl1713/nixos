# user/packages/editors/default.nix

{ config, lib, ... }:

with lib;

let cfg = config.userPackages.editors;
in {
  imports = [ ./neovim ];

  options.userPackages.editors = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable editor configurations";
    };

    neovim = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Neovim editor";
      };
    };
  };

  config = mkIf cfg.enable {
    # Global editor configurations can go here if needed
  };
}
