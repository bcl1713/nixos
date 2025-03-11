{
  description = "My Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      userSettings = rec {
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
	  modules = [ 
	    ./home.nix 
	  ];
	  extraSpecialArgs = {
	    inherit userSettings;
	  };
	};
      };
      nixosConfigurations = {
        nixbook = lib.nixosSystem {
	  inherit system;
	  modules = [ ./profiles/personal/configuration.nix ];
        };
      };
    };
}
