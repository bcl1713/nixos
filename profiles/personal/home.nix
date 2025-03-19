# profiles/personal/home.nix

{ userSettings, ... }:

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
    ../../user/fonts/fonts.nix
    ../../user/wm
    ../../user/scripts/directory-combiner.nix
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
  };

  programs.directory-combiner.enable = true;

}
