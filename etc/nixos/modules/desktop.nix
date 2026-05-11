{ pkgs, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Asia/Dhaka";

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  programs.xwayland.enable = true;

  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    epiphany
    geary
    gnome-calendar
    gnome-clocks
    gnome-console
    gnome-contacts
    gnome-maps
    gnome-music
    simple-scan
    snapshot
    gnome-text-editor
    gnome-connections
    yelp
  ];
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    dconf-editor
    papirus-icon-theme
    gnomeExtensions.user-themes
    brave
    alacritty
  ];
}
