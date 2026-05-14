{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    file
    curl
    git
    gnutar
    jq
    neovim
    tmux
    unzip
    wget
    zip
  ];
}
