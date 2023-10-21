# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, 
  inputs,
  outputs, ... }:
{
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
  
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.kernelModules = [ "amdgpu" ];
  };
  
  nix.settings = {
    experimental-features = [ "flakes" "nix-command" ]; #
    substituters = [
     # "https://hyprland.cachix.org"
     ];
    trusted-public-keys = [
     # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
     ]; 
  };
  
  networking = {
    hostName = "catputer";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Bangkok"; # tz

  i18n.defaultLocale = "en_AU.UTF-8"; # locale
  
  sound.enable = true; # sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  }; # sound

  hardware.opengl = {
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    driSupport = true;
    driSupport32Bit = true;
  };
  
  nixpkgs.config.allowUnfree = true;
  programs = {
    fish.enable = true;
    steam.enable = true;
  };
  
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
      steamguard-cli
    ]; # user packages
  }; # user

  environment.systemPackages = with pkgs; [ # sys packages
    (wrapOBS { plugins = with obs-studio-plugins; [ 
      obs-vkcapture 
      obs-gstreamer ];
      })
    lazygit
    nil
  ]; # sys packages
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
