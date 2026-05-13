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
    gnome-tweaks
    dconf-editor
    papirus-icon-theme
    gnomeExtensions.user-themes
    brave
    alacritty
  ];
}
