# user/packages/fonts/default.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.fonts;
in {
  options.userPackages.fonts = {
    enable = mkEnableOption "Enable custom fonts";

    nerdFonts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Nerd Fonts";
      };

      firaCode = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable FiraCode Nerd Font";
        };
      };
    };

    systemFonts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable system fonts";
      };
    };
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs;
      [ liberation_ttf noto-fonts noto-fonts-emoji ]
      ++ (optionals (cfg.nerdFonts.enable && cfg.nerdFonts.firaCode.enable)
        [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ])
      ++ (optionals cfg.systemFonts.enable [
        fira-code
        fira-code-symbols
        font-awesome
        proggyfonts
      ]);
  };
}
