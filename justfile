# Common home-manager commands. Install with `brew install just` or
# `nix-env -iA nixpkgs.just`.
#
# Usage:
#   just                 # show this help
#   just switch          # apply the current user's configuration
#   just switch oli      # apply the oli configuration
#   just update          # deliberately update flake inputs + switch
#   just gc              # delete nix store generations older than 30 days

default:
    @just --list

# Apply a home-manager configuration (default: oliverkelly)
switch user := "oliverkelly":
    home-manager switch --flake .#{{user}}

# Deliberately update flake inputs (nixpkgs, home-manager) and switch.
# Prefer this over a bare `nix flake update` so updates are intentional.
update user := "oliverkelly":
    nix flake lock --update-input nixpkgs
    nix flake lock --update-input home-manager
    home-manager switch --flake .#{{user}}

# Garbage-collect nix store generations older than 30 days
gc:
    nix-collect-garbage --delete-older-than 30d
