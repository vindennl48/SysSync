{
  description = "Just to create a lock file";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    ## DARWIN/MAC ##
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew }:
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macnix" = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self; 
        inherit nix-homebrew;
      };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
