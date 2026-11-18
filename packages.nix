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
  # every unfree package in nixpkgs.
  nixpkgs.config.allowUnfreePredicate = pkg:
    lib.elem (lib.getName pkg)
      [ "spotify" "vlc" "marp-cli" "pgadmin4-desktopmode" ];

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
  ];

  # Let Home Manager install and manage itself (per-user, but harmless
  # here since both users share this file).
  programs.home-manager.enable = true;
}
