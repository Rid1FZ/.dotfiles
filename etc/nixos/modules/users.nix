{ pkgs, ... }:
{
  users.users.rid1 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "adbusers"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      eza
      bat
      fzf
      ripgrep
      tree-sitter
      delta
      trash-cli
      github-cli

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
  };
}
