# user/packages/development/github.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.development.github;
in {
  options.userPackages.development.github = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable GitHub CLI and related tools";
    };
    enableCompletions = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GitHub shell completions";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gh ];

    # Shell completions
    programs.bash.enableCompletion = mkIf cfg.enableCompletions true;
    programs.zsh.enableCompletion = mkIf cfg.enableCompletions true;

    # Install completions if shell is enabled
    programs.zsh.initExtra =
      mkIf (cfg.enableCompletions && config.programs.zsh.enable) ''
        # GitHub CLI completions
        if [ -f ${pkgs.gh}/share/zsh/site-functions/_gh ]; then
          source ${pkgs.gh}/share/zsh/site-functions/_gh
        fi
      '';
  };
}
