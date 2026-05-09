{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    wget
    alacritty
    gnutar
    zip
    unzip
    tmux
    git
    gnome-tweaks
    dconf-editor
    papirus-icon-theme
    gnomeExtensions.user-themes
    brave
    uv
    python3
    rustup
    gcc
    lua
    luajit
    luarocks
    sqlite
    mariadb
    sqlfluff
    jdk17
    gradle
    android-tools
  ];

  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;

  programs.firefox.enable = false;

  services.openssh.enable = true;
}
