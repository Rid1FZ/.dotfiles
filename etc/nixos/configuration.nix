{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/users.nix
    ./modules/development.nix
    ./modules/packages.nix
  ];

  system.stateVersion = "25.11";
}
