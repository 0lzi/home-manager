# Common home-manager commands. `just` is not in PATH in this environment;
# run via the nix store, e.g.:
#   nix run nixpkgs#just -- --list
#   nix run nixpkgs#just -- dry-run
#
# Usage:
#   just                 # show this help
#   just switch          # apply the current user's configuration
#   just switch oli      # apply the oli configuration
#   just dry-run         # switch oliverkelly with --dry-run (no changes)
#   just dry-run oli     # switch oli with --dry-run (no changes)
#   just build           # build the activation package only (no install)
#   just update          # deliberately update flake inputs + switch
#   just gc              # delete nix store generations older than 30 days

default:
    @just --list

# Apply a home-manager configuration (default: oliverkelly)
switch user="oliverkelly":
    home-manager switch --flake .#{{user}}

# Preview a home-manager switch without applying it (default: oliverkelly).
# Same as `switch`, but with --dry-run: the configuration is evaluated and
# the planned changes are listed, but nothing is installed or modified.
dry-run user="oliverkelly":
    home-manager switch --dry-run --flake .#{{user}}

# Build the activation package only (default: oliverkelly) — evaluates the
# configuration and builds everything into the nix store without installing
# or modifying anything. Good for a CI-style check that the config is valid.
build user="oliverkelly":
    nix build --impure .#homeConfigurations.{{user}}.activationPackage

# Deliberately update flake inputs (nixpkgs, home-manager) and switch.
# Prefer this over a bare `nix flake update` so updates are intentional.
update user="oliverkelly":
    nix flake lock --update-input nixpkgs
    nix flake lock --update-input home-manager
    home-manager switch --flake .#{{user}}

# Garbage-collect nix store generations older than 30 days
gc:
    nix-collect-garbage --delete-older-than 30d
