# profiles/personal/home.nix

{ pkgs, userSettings, inputs, ... }:

{
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [ ../../user/packages inputs.agenix.homeManagerModules.default ];

  age = {
    identityPaths = [ "/home/${userSettings.username}/.ssh/id_ed25519" ];
    secrets = {
      personal-email = { file = ../../secrets/personal-email.age; };
    };
  };

  userPackages = {

    wm = {
      enable = true;
      hyprland = {
        enable = true;
        swaylock.enable = true;
        swayidle.enable = true;
      };
      waybar.enable = true;
    };

    fonts = {
      enable = true;
      nerdFonts.enable = true;
      systemFonts.enable = true;
    };

    system.enable = true;

    development = {
      enable = true;
      nix.enable = true;
      markdown.enable = true;
      nodejs.enable = true;
      python.enable = true;
      tooling.enable = true;
    };

    media = {
      enable = true;
      audio.enable = true;
      video.enable = true;
      image.enable = true;
    };

    utilities = {
      enable = true;
      diskUsage = {
        enable = true;
        interactiveTools.enable = true;
        graphicalTools.enable = true;
        duplicateFinder.enable = true;
        cleanupTools.enable = true;
      };
      system = {
        enable = true;
        monitoring = {
          enable = true;
          topTools.enable = true;
          graphical.enable = true;
          waybar = {
            enable = true;
            cpu.enable = true;
            memory.enable = true;
            disk.enable = true;
            temperature.enable = true;
          };
        };
      };
      files.enable = true;
      wayland.enable = true;
      clipboard.enable = true;
      screenRecording.enable = true;
      rofi.enable = false;
      screenshot.enable = true;
      bitwarden.enable = true;
      systemUpdates = {
        enable = true;
        homeManager = { enable = true; };
        system = { allowReboot = false; };
        notifications = {
          enable = true;
          beforeUpdate = true;
          afterUpdate = true;
        };
        maintenance = {
          garbageCollection = {
            enable = true;
            maxAge = 30;
            frequency = "weekly";
          };
          optimizeStore = true;
        };
      };
      powerManagement = {
        enable = true;
        defaultProfile = "balanced";
        keybinding = "SUPER, F7";
        indicator.enable = true;
      };

      wofi = {
        enable = true;
        modes = {
          drun.enable = true;
          window.enable = true;
          emoji.enable = true;
        };
      };
    };

    editors = {
      enable = true;
      neovim = {
        enable = true;
        plugins = {
          enable = true;
          lsp.enable = true;
          git.enable = true;
          markdown.enable = true;
        };
      };
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.sessionVariables = { EDITOR = "nvim"; };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -al";
      nss = "sudo nixos-rebuild switch --flake ~/.dotfiles/";
      hms = "home-manager switch --flake ~/.dotfiles/";
    };
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
    };
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
    ];
  };

}
