# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      mwe = import ./home.nix;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.kernelModules = ["amdgpu"];
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking = {
    hostName = "catputer";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Bangkok";

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

  users.users.mwe = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
      (discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      telegram-desktop
      steamguard-cli
      spotify
    ];
  };

  environment.systemPackages = with pkgs; [
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-vkcapture
      ];
    })
    lazygit
    nil
    cachix
    (nerdfonts.override {fonts = ["MPlus"];})
    inputs.getchvim.packages."x86_64-linux".default # shout in getchoo
    blackbox-terminal
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
