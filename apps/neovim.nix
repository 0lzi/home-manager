{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viMode = true;
    # Use the Nerd Font from packages.nix (nerd-fonts.hack) so the
    # pi-coding-agent / TUI blocks render correctly.
    options.guifont = "Hack Nerd Font:h14";
  };
}
