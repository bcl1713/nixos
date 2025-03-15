# user/app/neovim/neovim.nix

{ config, pkgs, userSettings, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };

  programs.ripgrep.enable = true;

  ## Add check for wayland vs x11.  Setting x11 for now.
  home.packages = with pkgs; [
    xclip
  ];

  home.file."${config.xdg.configHome}/nvim" = {
    source = ./.;
    recursive = true;
  };
}
