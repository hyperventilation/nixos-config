{
  description = "a flake";

  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      catputer = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./configuration.nix
                    ./gnome.nix ];
      };
    };

    # 'home-manager --flake .#user@host'
    homeConfigurations = {
      "mwe@catputer" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        useGlobalPkgs = true; 
        extraSpecialArgs = { inherit inputs; }; 
        modules = [ ./home.nix ];
      };
    };
  };
}
