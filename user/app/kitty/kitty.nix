# user/app/kitty/kitty.nix

{ config, pkgs, ... }:

{
  programs.kitty = {
	  enable = true;
		font = {
		  name = "FiraCode Nerd Font Mono";
		};
		themeFile = "Catppuccin-Mocha";
  };
}
