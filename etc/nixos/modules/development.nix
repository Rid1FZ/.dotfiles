{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings = {
    max-jobs = "auto";
    cores = 0; # use all cores per job
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      glib
    ];
  };

  services.udev.packages = [ pkgs.android-tools ];

  environment.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    ANDROID_HOME = "$HOME/Android/Sdk";
    JAVA_HOME = "${pkgs.jdk17}";
    PATH = [
      "$HOME/Android/Sdk/cmdline-tools/latest/bin"
      "$HOME/.local/bin"
      "$HOME/bin"
      "$HOME/.cargo/bin"
    ];
  };

  environment.systemPackages = with pkgs; [
    uv
    python3
    rustup
    go
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
}
