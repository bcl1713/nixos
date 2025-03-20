# profiles/personal/home.nix

{ pkgs, userSettings, ... }:

{
  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [ 
    ../../user/app/git/git.nix
    ../../user/app/neovim/neovim.nix
    ../../user/app/firefox/firefox.nix
    ../../user/app/nextcloud/nextcloud.nix
    ../../user/app/kitty/kitty.nix
    ../../user/app/prusa/prusa.nix
    ../../user/fonts/fonts.nix
    ../../user/wm
    ../../user/scripts/directory-combiner.nix
    ../../user/scripts/wifi-menu.nix
    ../../user/scripts/battery-warning.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    glow
    nodePackages.markdownlint-cli2
  ];

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

  programs.directory-combiner.enable = true;

}
