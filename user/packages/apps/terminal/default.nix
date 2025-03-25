# user/packages/apps/terminal/default.nix

{ config, lib, ... }:

with lib;

let cfg = config.userPackages.apps.terminal;
in {
  options.userPackages.apps.terminal = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable terminal applications";
    };

    kitty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Kitty terminal";
      };

      font = {
        family = mkOption {
          type = types.str;
          default = "FiraCode Nerd Font Mono";
          description = "Font family for Kitty terminal";
        };

        size = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Font size for Kitty terminal (null uses default)";
        };
      };

      theme = mkOption {
        type = types.str;
        default = "Catppuccin-Mocha";
        description = "Theme for Kitty terminal";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.kitty.enable {
      programs.kitty = {
        enable = true;
        font = {
          name = cfg.kitty.font.family;
          size = cfg.kitty.font.size;
        };
        themeFile = cfg.kitty.theme;
      };
    })
  ]);
}
