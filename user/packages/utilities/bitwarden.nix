# user/packages/utilities/bitwarden.nix

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.bitwarden;
in {
  options.userPackages.utilities.bitwarden = {
    enable = mkEnableOption "Enable Bitwarden password manager";

    desktop = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Bitwarden desktop client";
      };

      autostart = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to autostart Bitwarden desktop client";
      };
    };

    cli = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Bitwarden CLI";
      };

      addShellAliases = mkOption {
        type = types.bool;
        default = true;
        description = "Add useful shell aliases for Bitwarden CLI";
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.desktop.enable) {
      # Install the Bitwarden desktop client
      home.packages = with pkgs; [ bitwarden ];

      # Autostart Bitwarden if enabled
      systemd.user.services.bitwarden = mkIf cfg.desktop.autostart {
        Unit = {
          Description = "Bitwarden password manager";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };

        Service = {
          ExecStart = "${pkgs.bitwarden}/bin/bitwarden";
          Restart = "on-failure";
        };
      };
    })

    (mkIf (cfg.enable && cfg.cli.enable) {
      # Install the Bitwarden CLI
      home.packages = with pkgs; [ bitwarden-cli ];

      # Add useful shell aliases if enabled
      programs.bash.shellAliases = mkIf cfg.cli.addShellAliases {
        bw-unlock = "export BW_SESSION=$(bw unlock --raw)";
        bw-lock = "bw lock && unset BW_SESSION";
        bw-status = "bw status";
        bw-sync = "bw sync";
      };

      programs.zsh.shellAliases = mkIf cfg.cli.addShellAliases {
        bw-unlock = "export BW_SESSION=$(bw unlock --raw)";
        bw-lock = "bw lock && unset BW_SESSION";
        bw-status = "bw status";
        bw-sync = "bw sync";
      };
    })
  ];
}
