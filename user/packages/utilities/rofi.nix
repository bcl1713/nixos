# user/packages/utilities/rofi.nix
#
# This module provides Rofi as an alternative application launcher with
# multiple modes and Catppuccin theming for consistent appearance.

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.userPackages.utilities.rofi;
in {
  options.userPackages.utilities.rofi = {
    enable = mkEnableOption "Enable Rofi application launcher";

    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Terminal to use for terminal commands";
    };

    theme = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Catppuccin theming for Rofi";
      };

      borderRadius = mkOption {
        type = types.int;
        default = 8;
        description = "Border radius for Rofi windows";
      };
    };

    modes = {
      drun = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable application launcher mode";
        };

        keybinding = mkOption {
          type = types.str;
          default = "SUPER, space";
          description = "Hyprland keybinding for application launcher mode";
        };
      };

      window = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable window switcher mode";
        };

        keybinding = mkOption {
          type = types.str;
          default = "SUPER, Tab";
          description = "Hyprland keybinding for window switcher mode";
        };
      };

      emoji = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable emoji picker mode";
        };

        keybinding = mkOption {
          type = types.str;
          default = "SUPER SHIFT, e";
          description = "Hyprland keybinding for emoji picker mode";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Install Rofi and plugins
    home.packages = with pkgs; [ rofi-wayland rofimoji ];

    # Configure Rofi
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = cfg.terminal;
    };

    # Create Rofi configuration files
    xdg.configFile = {
      "rofi/config.rasi".text = ''
        configuration {
          modi: "drun,window";
          terminal: "${cfg.terminal}";
          show-icons: true;
          icon-theme: "Papirus";
          drun-display-format: "{name}";
          disable-history: false;
          hide-scrollbar: true;
          display-drun: "Applications ";
          display-window: "Windows ";
          sidebar-mode: true;
        }

        @theme "${config.xdg.configHome}/rofi/catppuccin-mocha.rasi"
      '';

      # Create theme file if theming is enabled
      "rofi/catppuccin-mocha.rasi" = mkIf cfg.theme.enable {
        text = ''
          * {
              bg-col:  #1e1e2e;
              bg-col-light: #313244;
              border-col: #89b4fa;
              selected-col: #45475a;
              blue: #89b4fa;
              fg-col: #cdd6f4;
              fg-col2: #f38ba8;
              grey: #6c7086;
              width: 600;
              font: "FiraCode Nerd Font 12";
          }

          element-text, element-icon , mode-switcher {
              background-color: inherit;
              text-color:       inherit;
          }

          window {
              height: 360px;
              border: 3px;
              border-color: @border-col;
              border-radius: ${toString cfg.theme.borderRadius}px;
              background-color: @bg-col;
          }

          mainbox {
              background-color: @bg-col;
          }

          inputbar {
              children: [prompt,entry];
              background-color: @bg-col;
              border-radius: ${toString cfg.theme.borderRadius}px;
              padding: 2px;
          }

          prompt {
              background-color: @blue;
              padding: 6px;
              text-color: @bg-col;
              border-radius: ${toString (cfg.theme.borderRadius - 2)}px;
              margin: 20px 0px 0px 20px;
          }

          textbox-prompt-colon {
              expand: false;
              str: ":";
          }

          entry {
              padding: 6px;
              margin: 20px 0px 0px 10px;
              text-color: @fg-col;
              background-color: @bg-col;
          }

          listview {
              border: 0px 0px 0px;
              padding: 6px 0px 0px;
              margin: 10px 0px 0px 20px;
              columns: 1;
              lines: 10;
              background-color: @bg-col;
          }

          element {
              padding: 5px;
              background-color: @bg-col;
              text-color: @fg-col;
              border-radius: ${toString (cfg.theme.borderRadius - 4)}px;
          }

          element-icon {
              size: 25px;
          }

          element selected {
              background-color:  @selected-col;
              text-color: @fg-col2;
          }

          mode-switcher {
              spacing: 0;
          }

          button {
              padding: 10px;
              background-color: @bg-col-light;
              text-color: @grey;
              vertical-align: 0.5; 
              horizontal-align: 0.5;
          }

          button selected {
              background-color: @bg-col;
              text-color: @blue;
          }

          message {
              background-color: @bg-col-light;
              margin: 2px;
              padding: 2px;
              border-radius: ${toString (cfg.theme.borderRadius - 4)}px;
          }

          textbox {
              padding: 6px;
              margin: 20px 0px 0px 20px;
              text-color: @fg-col;
              background-color: @bg-col-light;
          }
        '';
      };
    };

    # Update Hyprland keybindings if Hyprland is enabled
    wayland.windowManager.hyprland.extraConfig =
      mkIf config.wayland.windowManager.hyprland.enable (
        # Add all enabled rofi bindings
        (if cfg.modes.drun.enable then ''
          bind = ${cfg.modes.drun.keybinding}, exec, rofi -show drun
        '' else
          "") + (if cfg.modes.window.enable then ''
            bind = ${cfg.modes.window.keybinding}, exec, rofi -show window
          '' else
            "") + (if cfg.modes.emoji.enable then ''
              bind = ${cfg.modes.emoji.keybinding}, exec, rofimoji --action copy --skin-tone neutral
            '' else
              ""));
  };
}
