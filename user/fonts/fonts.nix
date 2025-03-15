# usr/fonts/fonts.nix

{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-emoji
    proggyfonts
  ];
}
