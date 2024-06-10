{
  description = "a slightly cooler computer flake";

  nixConfig = {
    accept-flake-config = true;
    extra-substituters =
      [ "https://nix-community.cachix.org" "https://devenv.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # abaddon-sf.url = "github:SeineEloquenz/nixpkgs/abbadon_sound_fix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      imports = [
        ./hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        extraSpecialArgs = { inherit inputs self; };
        users.mwe = import ./home.nix;
      };

      boot = {
        kernelPackages = pkgs.linuxPackages_zen;
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        initrd.kernelModules = [ "amdgpu" ];
      };

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };

      systemd.coredump.enable = false;
      networking = {
        hostName = "catputer";
        nameservers = [ "1.1.1.1" "9.9.9.9" ];
        networkmanager.enable = true;
      };

      time.timeZone = "Asia/Bangkok"; # funny city am i right

      i18n.defaultLocale = "en_AU.UTF-8";

      sound.enable = true;
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
      # bye ogl

      nixpkgs.config = {
        allowUnfree = true;
        allowInsecure = true;
      };

      programs = {
        fish.enable = true;
        steam.enable = true;
      };

      users.users.mwe = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.fish;
        packages = with pkgs; [
          firefox
          vesktop
          telegram-desktop
          steamguard-cli
          spotify
          obsidian
          obs-studio
          jetbrains.rust-rover
        ]; # ++ (with abaddon-sf; [ abaddon ]);
      };

      environment.systemPackages = with pkgs; [
        helix
        lazygit
        (nerdfonts.override { fonts = [ "MPlus" ]; })
        blackbox-terminal
        cachix
        corectrl
      ];
      system.stateVersion = "23.05";
    };

    nixosConfigurations = {
      catputer = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ self.nixosModules.default ./gnome.nix ];
      };
    };

    # 'home-manager --flake .#user@host'
    homeConfigurations = {
      "mwe@catputer" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          config.allowInsecure = true;
        };
        useGlobalPkgs = true;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
  };
}
