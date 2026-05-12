{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings = {
    max-jobs = "auto";
    cores = 0; # use all cores per job
    warn-dirty = false;
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
    ANDROID_HOME = "$HOME/Android/Sdk";
    JAVA_HOME = "${pkgs.jdk17}";
    PATH = [
      "$HOME/Android/Sdk/cmdline-tools/latest/bin"
      "$HOME/.local/bin"
      "$HOME/bin"
      "$HOME/.cargo/bin"
    ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
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

    # Bash
    bash-language-server
    shfmt
    shellcheck

    # Python
    pyright
    ruff

    # Lua
    lua-language-server
    stylua

    # C/Cpp
    clang-tools

    # Docker
    docker-language-server

    # Nix
    nixd
    nixfmt

    # Go
    gopls
    gotools
    golangci-lint
  ];
}
