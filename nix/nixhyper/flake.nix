{
  description = "Just to create a lock file";

  inputs = {
    # nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
  };

  outputs = inputs@{ self, nixpkgs }:
  {
    nixosConfigurations."nixhyper" = nixpkgs.lib.nixosSystem {
      modules = [
        /etc/nixos/configuration.nix
      ];
    };
  };
}
