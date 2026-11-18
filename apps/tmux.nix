{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    historyLimit = 20000;
    baseIndex = 1;
    # "tmux-256color" is a no-op alias for "screen" since tmux 3.2;
    # xterm-256color keeps terminal-overrides working as expected.
    terminal = "xterm-256color";
    # sensibleOnTop defaults to true (tmux-sensible options are written
    # *before* extraConfig so our overrides win) — keep the default.

    # tmux-sessionizer per-directory binds are generated from a single
    # list (below) so the config doesn't rot when repos move.
    sessionizerBinds = pkgs.lib.concatStringsSep "\n" (map (entry: ''
      bind-key -r ${entry.key} run-shell "~/.local/bin/scripts/tmux-sessionizer ${entry.path}"
    '') [
      { key = "f"; path = ""; }
      { key = "O"; path = "~/git/ops-internal/overview/"; }
      { key = "N"; path = "~/git/network-automation/network-ansible"; }
      { key = "P"; path = "~/git-personal/"; }
      { key = "B"; path = "~/git/netbox/"; }
      { key = "S"; path = "~/git/openstack/"; }
      { key = "G"; path = "~/git/"; }
      { key = "E"; path = "~/git/elk/"; }
      { key = "T"; path = "~/git/terraops"; }
      { key = "H"; path = "~/"; }
      { key = "V"; path = "~/git/vyos/"; }
    ]) + "\n";

    extraConfig = (builtins.readFile ../dotfiles/tmux.conf) + config.programs.tmux.sessionizerBinds;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '30' # minutes
        '';
      }
      {
        plugin = tmuxPlugins.vim-tmux-navigator;
      }
      {
        plugin = tmuxPlugins.yank;
      }
    ];
  };
}
