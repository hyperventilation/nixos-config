{pkgs, ...}: {
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "us";
    excludePackages = [pkgs.xterm];
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
      ]
      ++ (with gnome; [
        gnome-font-viewer
        gnome-weather
        gnome-calendar
        seahorse
        cheese # webcam tool
        gnome-music
        gedit # text editor
        epiphany # web browser
        geary # email reader
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
        gnome-maps
        gnome-system-monitor
        simple-scan
        gnome-logs
      ]);
    systemPackages = [pkgs.gnome.gnome-tweaks];
  };
}
