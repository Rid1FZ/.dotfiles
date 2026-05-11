{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    wget
    gnutar
    zip
    unzip
    tmux
    git
    file
    curl
    jq
  ];
}
