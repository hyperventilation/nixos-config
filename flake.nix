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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosModules.default = { config, pkgs, lib, ... }: {
      imports = [ ./hardware-configuration.nix ];

      home-manager = {
        extraSpecialArgs = { inherit inputs self; };
        users.hv = import ./home.nix;
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

      time.timeZone = "Asia/Bangkok";

      i18n.defaultLocale = "en_AU.UTF-8";

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

      nixpkgs.config = {
        allowUnfree = true;
        allowInsecure = true;
      };

      programs = {
        fish.enable = true;
        steam.enable = true;
      };

      users.users.hv = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.fish;
        packages = with pkgs; [
          chromium
          (pkgs.discord.override {
            withOpenASAR = true;
            withVencord = true;
          })
          telegram-desktop
          steamguard-cli
          spotify
          obsidian
          obs-studio
          vscode-fhs
        ];
      };

      environment.systemPackages = with pkgs; [
        helix
        lazygit
        (nerdfonts.override { fonts = [ "MPlus" ]; })
        blackbox-terminal
        cachix
        corectrl
        devenv
      ];
      system.stateVersion = "24.05";
    };

    nixosModules.gnome = { pkgs, ... }: {
      services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        xkb.layout = "us";
        excludePackages = [ pkgs.xterm ];
      };

      programs.dconf.enable = true; # ./home.nix

      environment = {
        gnome.excludePackages = with pkgs;
          [
            gnome-photos
            gnome-tour
            gnome-console
            gnome-connections
            gnome-text-editor
            evince # nice naming conventions
            gedit
            geary
            epiphany
            cheese
            seahorse
            gnome-calendar
            # gnome-font-viewer
          ] ++ (with gnome; [
            gnome-weather
            gnome-music
            gnome-characters
            tali
            iagno
            hitori
            atomix
            gnome-contacts
            gnome-initial-setup
            gnome-maps
            gnome-logs
          ]);
        systemPackages = [ pkgs.gnome-tweaks ];
      };
    };

    nixosModules.plasma = { pkgs, ... }: {
      services = {
        xserver.enable = true;
        displayManager = {
          sddm.enable = true;
          defaultSession = "plasmax11";
        };
        desktopManager.plasma6.enable = true;
      };
    };

    nixosConfigurations = {
      catputer = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          self.nixosModules.default
          self.nixosModules.gnome
          home-manager.nixosModules.home-manager
          { home-manager.users.hv = { imports = [ ./home.nix ]; }; }
        ];
      };
    };
  };
}
