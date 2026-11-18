{ config, lib, pkgs, ... }:

{
  # Shared per-app modules live in ./apps and are imported here so the
  # per-user files (work.nix / oli.nix) only need to set the username,
  # home directory and stateVersion.
  imports = [
    ./apps/tmux.nix
    ./apps/neovim.nix
  ];

  # Only allow the specific unfree packages we actually use, rather than
  # every unfree package in nixpkgs. (The BSL-licensed HashiCorp tools
  # terraform/consul/packer and spotify are the only unfree packages in
  # home.packages; the rest are free. `nix build` fails loudly if a new
  # unfree package is added without updating this list.)
  nixpkgs.config.allowUnfreePredicate = pkg:
    lib.elem (lib.getName pkg)
      [ "terraform" "consul" "packer" "spotify" ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # General
    htop
    fastfetch
    vlc
    spotify
    virt-manager
    lazygit
    bat
    lazydocker
    unzip
    ripgrep
    keepassxc
    quasselClient
    nerd-fonts.hack

    # Kubernetes
    kubectl
    kustomize
    kubernetes-helm
    k9s

    # Secrets / scanning
    trufflehog
    yubikey-manager

    # Hashicorp type things
    terraform
    opentofu
    openbao
    consul
    packer

    # Language toolchains
    cargo
    uv
    go
    direnv
    nix-direnv

    # AI stuff
    pi-coding-agent
    socat
    # rtk (https://github.com/steffengy/rtk) rewrites bash commands for token
    # savings; the pi extension at ~/.pi/agent/extensions/rtk.ts shells out to
    # it. It is a nixpkgs package in the locked nixpkgs-unstable (1.1.0).
    # An older manual ~/.config/bin/rtk symlink (rust-bin build) is obsolete
    # now that HM manages rtk via the profile; it may be removed.
    rtk
  ];

  # Let Home Manager install and manage itself (per-user, but harmless
  # here since both users share this file).
  programs.home-manager.enable = true;
}
