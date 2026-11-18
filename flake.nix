{
  description = "My Ubuntu Nix";

  inputs = {
    # Keep nixpkgs-unstable but only update it deliberately:
    #   nix flake lock --update-input nixpkgs
    # and commit the lock. Don't casually run `nix flake update`.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      # Pin to a release branch rather than master to reduce breakage.
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    ... }: let
    # Default to the build host's architecture; pass `--system
    # aarch64-linux` to target ARM instead.
    system = inputs.system or builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations = {
      oliverkelly = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./work.nix
          ./packages.nix
        ];
      };
      oli = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./oli.nix
          ./packages.nix
        ];
      };
    };
  };
}

