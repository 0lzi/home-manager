{ config, pkgs, ... }:

{
  imports = [
   ./apps/tmux.nix
   ./apps/neovim.nix
  ];

  nixpkgs.config.allowUnfreePredicate = _: true;
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    htop
    neofetch
    vlc
    spotify
    virt-manager
    lazygit
    marp-cli
    unzip
    kubectl
    kustomize
    kubernetes-helm
    k9s
    trufflehog
# Hashicorp type things
    terraform
    opentofu
    openbao
    consul
    packer
#######################
    keepassxc
    quasselClient
    cargo
    uv
    direnv
    nix-direnv
    go
    bat
    lazydocker
    pgadmin4-desktopmode
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    nerd-fonts.hack
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
