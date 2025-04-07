# user/packages/development/default.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.development;
in {
  imports = [ ./github.nix ];
  options.userPackages.development = {
    enable = mkEnableOption "Enable development tools";

    nix = { enable = mkEnableOption "Enable Nix development tools"; };

    markdown = { enable = mkEnableOption "Enable Markdown tools"; };

    nodejs = { enable = mkEnableOption "Enable Node.js development tools"; };

    python = { enable = mkEnableOption "Enable Python development tools"; };

    tooling = { enable = mkEnableOption "Enable general development tooling"; };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.nix.enable) {
      home.packages = with pkgs; [ nixfmt-classic nil ];
    })
    (mkIf (cfg.enable && cfg.nodejs.enable) {
      home.packages = with pkgs; [ nodejs nodePackages.npm nodePackages.yarn ];
    })
    (mkIf (cfg.enable && cfg.python.enable) {
      home.packages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.black
        python3Packages.flake8
      ];
    })
    (mkIf (cfg.enable && cfg.tooling.enable) {
      home.packages = with pkgs; [ ripgrep fd jq direnv ];
    })
  ];
}
