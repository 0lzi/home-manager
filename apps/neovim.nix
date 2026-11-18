{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # Use the Nerd Font from packages.nix (nerd-fonts.hack) so the
    # pi-coding-agent / TUI blocks render correctly.
    extraConfig = ''
      set guifont=Hack\ Nerd\ Font:h14
    '';
    # ~/.config/nvim contains a hand-managed NvChad setup (init.lua +
    # configs/ + plugins/). HM's default init.lua would clobber it; the
    # empty string makes HM generate no managed init.lua, leaving the
    # hand-written one untouched. HM then only manages the editor binary
    # (via home.packages) and the guifont line above.
    initLua = "";
  };
}
