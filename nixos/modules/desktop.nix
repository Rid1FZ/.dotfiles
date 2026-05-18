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
    epiphany
    geary
    gnome-calendar
    gnome-clocks
    gnome-connections
    gnome-console
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-text-editor
    gnome-tour
    gnome-user-docs
    gnome-weather
    simple-scan
    snapshot
    yelp
  ];
  services.gnome.tinysparql.enable = false;
  services.gnome.localsearch.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      adwaita-fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      lohit-fonts.bengali
    ];
    fontconfig = {
      defaultFonts.sansSerif = [ "Adwaita Sans" ];
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <alias>
            <family>sans-serif</family>
            <prefer>
              <family>Lohit Bengali</family>
            </prefer>
          </alias>
          <alias>
            <family>serif</family>
            <prefer>
              <family>Lohit Bengali</family>
            </prefer>
          </alias>
        </fontconfig>
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    brave
    dconf-editor
    gnome-tweaks
    gnomeExtensions.user-themes
    papirus-icon-theme
  ];
}
