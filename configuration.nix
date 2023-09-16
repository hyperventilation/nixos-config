# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, 
  inputs, outputs, ... }: {
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      mwe = import ./home.nix;
    };
  };

  boot.loader.systemd-boot.enable = true; # bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  nix.settings.experimental-features = [ "flakes" "nix-command" ]; # 

  networking.hostName = "catputer"; # networking, hostname
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Bangkok"; # tz

  i18n.defaultLocale = "en_US.UTF-8"; # locale
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  }; # locale

  services.xserver = { # TODO: move to ./gnome.nix; add stuff .
    layout = "us";
    xkbVariant = "";
  }; 
  
  sound.enable = true; # sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  }; # sound

  hardware.opengl = {
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
      amdvlk
    ];
    driSupport = true;
    driSupport32Bit = true;
  };
  
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true; # lol
  users.users.mwe = { # user
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [ # user packages
      firefox
      mangohud
      (discord.override {
      	withOpenASAR = true;
      	withVencord = true;
      })
      telegram-desktop
    ]; # user packages
  }; # user

  environment.systemPackages = with pkgs; [ # sys packages
    gnome.gnome-tweaks
    (wrapOBS { plugins = with obs-studio-plugins; [ 
      obs-vkcapture 
      obs-gstreamer ];
      })
    lazygit
  ]; # sys packages
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
