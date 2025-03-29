# user/wm/hyprland/hyprland.nix

{ config, pkgs, ... }:

let
  # Catppuccin Mocha Colors
  colors = {
    rosewater = "rgb(f5e0dc)";
    flamingo = "rgb(f2cdcd)";
    pink = "rgb(f5c2e7)";
    mauve = "rgb(cba6f7)";
    red = "rgb(f38ba8)";
    maroon = "rgb(eba0ac)";
    peach = "rgb(fab387)";
    yellow = "rgb(f9e2af)";
    green = "rgb(a6e3a1)";
    teal = "rgb(94e2d5)";
    sky = "rgb(89dceb)";
    sapphire = "rgb(74c7ec)";
    blue = "rgb(89b4fa)";
    lavender = "rgb(b4befe)";
    text = "rgb(cdd6f4)";
    subtext1 = "rgb(bac2de)";
    subtext0 = "rgb(a6adc8)";
    overlay2 = "rgb(9399b2)";
    overlay1 = "rgb(7f849c)";
    overlay0 = "rgb(6c7086)";
    surface2 = "rgb(585b70)";
    surface1 = "rgb(45475a)";
    surface0 = "rgb(313244)";
    base = "rgb(1e1e2e)";
    mantle = "rgb(181825)";
    crust = "rgb(11111b)";
  };
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    # Convert the hyprland.conf to Nix format
    settings = {
      "$terminal" = "kitty";
      "$fileManager" = "nautilus";
      "$browser" = "firefox";

      monitor = ",preferred,auto,1.6";

      # Autostart programs
      "exec-once" = [
        "waybar & hyprpaper"
        "mako"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hprland"
      ];

      # Environment variables
      env = [ "XCURSOR_SIZE,24" "HYPRCURSOR_SIZE,24" ];

      # General settings
      general = {
        border_size = 4;

        "col.active_border" = "${colors.blue} ${colors.green} 90deg";
        "col.inactive_border" = colors.subtext0;

        gaps_in = 8;
        gaps_out = 16;

        resize_on_border = true;
        allow_tearing = false;

        layout = "dwindle";
      };

      # Decoration settings
      decoration = {
        rounding = 4;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        active_opacity = 1.0;
        inactive_opacity = 0.8;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      # Animation settings
      animations = {
        enabled = true;

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      # Window rules
      windowrulev2 = [
        "fullscreenstate 0 2,class:(firefox)"
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      # Layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = { new_status = "master"; };

      # Misc settings
      misc = {
        force_default_wallpaper = 0;
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
        key_press_enables_dpms = true;
      };

      # Input settings
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        sensitivity = 0;

        touchpad = { natural_scroll = false; };
      };

      # Gesture settings
      gestures = { workspace_swipe = false; };

      # Device-specific settings
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # Keybindings
      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, P, pseudo,"
        "$mainMod, B, exec, $browser"
        "$mainMod, X, exec, lock-screen"

        # Movement keys
        "$mainMod, h, movefocus, l"
        "$mainMod, j, movefocus, d"
        "$mainMod, k, movefocus, u"
        "$mainMod, l, movefocus, r"

        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move windows to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Media key bindings
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };

  # Install packages related to Hyprland
  home.packages = with pkgs; [
    waybar
    hyprpaper
    swaylock
    swayidle
    wl-clipboard
    grim
    slurp
    networkmanagerapplet
    mako
  ];

  # Configuration files
  home.file = {
    "${config.xdg.configHome}/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    "${config.xdg.configHome}/hypr/background.png".source = ./background.png;
    "${config.xdg.configHome}/mako/config".text = ''
      sort=-time
      layer=overlay
      background-color=#1e1e2e
      width=300
      height=110
      border-size=2
      border-color=#89b4fa
      border-radius=4
      icons=1
      max-icon-size=64
      default-timeout=5000
      ignore-timeout=1
      font=FiraCode Nerd Font 10

      [urgency=low]
      border-color=#94e2d5

      [urgency=normal]
      border-color=#89b4fa

      [urgency=critical]
      border-color=#f38ba8
      default-timeout=0
    '';
  };

  # Swaylock configuration
  home.file."${config.xdg.configHome}/swaylock" = {
    source = ./swaylock;
    recursive = true;
  };
}
