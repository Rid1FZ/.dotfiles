{ pkgs, ... }:
{
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
    ## Tools
    libtool

    # SQL
    sqlite
    mariadb
    sqlfluff

    # Bash
    bash-language-server
    shfmt
    shellcheck

    # Python
    uv
    python3
    basedpyright
    ruff

    # Lua
    lua
    luajit
    luarocks
    lua-language-server
    stylua

    # C/Cpp
    gcc
    clang-tools
    cmake
    gnumake

    # Docker
    docker-language-server

    # Nix
    nixd
    nixfmt

    # Go
    go
    gopls
    gotools
    golangci-lint

    # Rust
    rustup

    # Java/Kotlin
    jdk17
    gradle
    android-tools
  ];
}
