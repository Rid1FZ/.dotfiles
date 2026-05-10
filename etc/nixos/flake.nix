{
  description = "Rid1's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations = {
        hp450 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/hp450/configuration.nix ];
        };
      };
    };
}
