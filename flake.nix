# flake.nix

{
  description = "My Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, agenix, ... }@inputs:
    let
      systemSettings = { profile = "personal"; };
      userSettings = {
        username = "brianl";
        name = "Brian Lucas";
        email = "bcl1713@gmail.com";
      };
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations = {
        brianl = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./profiles/${systemSettings.profile}/home.nix ];
          extraSpecialArgs = { inherit userSettings inputs; };
        };
      };
      nixosConfigurations = {
        nixbook = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./profiles/${systemSettings.profile}/configuration.nix
            agenix.nixosModules.default
          ];
        };
      };
    };
}
