{ pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule
    # You can also split up your configuration and import pieces of it here:
  ];

  nixpkgs = {
    overlays = [ ];
    config = { };
  };

  home = {
    username = "mwe";
    homeDirectory = "/home/mwe";
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/screensaver" = {
      "picture-uri" =
        "file://run/current-system/sw/share/backgrounds/gnome/fold-l.webp";
      "primary-color" = "#26a269";
    };
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
    "org/gnome/desktop/notifications/application/discord" = {
      enable = "false";
    };
    "org/gnome/desktop/peripherals/mouse" = { accel-profile = "flat"; };
    "org/gnome/desktop/wm/keybindings" = { close = [ ]; };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "terminate:ctrl_alt_bksp" "grp:alt_shift_toggle" ];
    };
    "com/raggesilver/BlackBox" = {
      font = "M+CodeLat60 Nerd Font Mono Medium Expanded 12";
    };
  };

  # Nicely reload system units when changing configs
  systemd = { user.startServices = "sd-switch"; };
  home.stateVersion = "23.05";
}
