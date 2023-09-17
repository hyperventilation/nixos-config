{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "us";
  };

  programs.dconf.enable = true;

  environment = {
    gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
      ]) ++ (with pkgs.gnome; [
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
    ]);
    systemPackages = [ pkgs.gnome.gnome-tweaks ];  
    };
}