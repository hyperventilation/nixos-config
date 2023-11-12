{
  description = "a computer flake";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw"
    ];
  };
  
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      catputer = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ 
        ./configuration.nix
        ./gnome.nix
        ];
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
