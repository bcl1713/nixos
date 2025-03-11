{ config, pkgs, userSettings, ... }:

{
  home.packages = [ pkgs.neovim ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
