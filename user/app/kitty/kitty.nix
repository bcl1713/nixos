# user/app/kitty/kitty.nix

{ ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font Mono";
    };
    themeFile = "Catppuccin-Mocha";
  };
}
