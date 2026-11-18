# Review & Suggestions

Reviewed: `packages.nix`, `flake.nix`, `work.nix`, `oli.nix`, `apps/tmux.nix`,
`apps/neovim.nix`, `dotfiles/tmux.conf`, `README.md`, `etc/nix/nix.conf`, git history.

## High priority

### 1. `rtk` is not a nixpkgs package — likely breaks `home-manager switch`
The latest commit ("test rtk") added `rtk` to `home.packages`. `rtk` (the Rust
CLI tool) is not in nixpkgs, so `with pkgs; [ ... rtk ... ]` will fail with
`attribute "rtk" missing`. If this is intentional (e.g. installed via
`cargo install rtk`), it should not be in `home.packages`. If you want it via
Nix, install it through `cargo`:

```nix
cargo = {
  enable = true;
  packageOverrides = (pkgs): with pkgs; [
    (pkgs.rust-bin.stable.latest.default.buildPackage "rtk" {
      owner = "steffengy"; repo = "rtk"; rev = "v0.x.y";
    })
  ];
};
```

or just drop it from the list. Note it also broke this shell: the wrapper
around `ls`/`find` in this environment fails with `rtk: command not found`.

### 2. `nixpkgs.config.allowUnfreePredicate = _: true;` is too broad
This allows *every* unfree package, not just the ones you need (e.g. Spotify).
Prefer an explicit predicate:

```nix
nixpkgs.config.allowUnfreePredicate = pkg:
  [ "spotify" "vlc" "marp-cli" "pgadmin4-desktopmode" ]
  ? (lib.getName pkg);
```

(Adjust the list to whatever actually needs it — `nix eval` errors will tell
you. `lib` is available as an attrset in HM modules? No — use
`nixpkgs.lib` via `{ config, lib, pkgs, ... }` in the module args.)

### 3. Commit "test rtk" is ahead of origin and looks like a test commit
`master` is 1 commit ahead of `origin/master` and that commit only adds the
broken `rtk` line. Consider fixing/reverting before pushing.

## Medium priority

### 4. Duplicate imports in `work.nix` and `oli.nix`
Both files import `./apps/tmux.nix` and `./apps/neovim.nix` and share 90% of
their content. Move the shared bits into `packages.nix` (or a `common.nix`)
and keep only `home.username` / `home.homeDirectory` / `home.stateVersion` in
the per-user files.

### 5. `apps/neovim.nix` is empty (`{ }`)
Either populate it (e.g. `programs.neovim.enable = true;`) or remove it and
the import. With `pi-coding-agent` and `nerd-fonts.hack` in the mix, a
`programs.neovim` block with the Nerd Font set would be a natural place.

### 6. `nixpkgs-unstable` + `home-manager` master is a moving target
You're pinning nothing: `nixpkgs-unstable` and the home-manager default branch
change daily. Two options:
- Pin to a stable channel (`nixpkgs-25.05` / release-25.05) and only move when
  you have time to fix breakage.
- Keep unstable but `nix flake lock --update-input nixpkgs` deliberately and
  commit the lock (which you already do — just don't update it casually).

### 7. `terminal = "tmux-256color"` is deprecated
Since tmux 3.2, `tmux-256color` is a no-op alias for `screen`. Prefer
`tmux-256color` → `xterm-256color` or just drop the option; if you want true
colour, `terminal = "tmux-truecolor"` (or rely on `terminal-features`).

### 8. tmux config duplication / dead code in `dotfiles/tmux.conf`
- `set -g base-index 1` and `pane-base-index` are set in *both* `apps/tmux.nix`
  (via `baseIndex = 1`) and the raw conf. Pick one place (the HM module is
  cleaner).
- The file still has a block of commented-out TPM plugin lines
  (`tmux-resurrect`, `tmux-continuum`, `catppuccin-tmux`, etc.) that duplicate
  the plugins now declared in `apps/tmux.nix`. Since you've moved plugins into
  the HM module, delete the TPM section and the trailing
  `run '~/.tmux/plugins/tpm/tpm'` — home-manager's tmux plugin management
  (which uses TPM internally) will handle it.
- `bind C-Space send-prefix` is a no-op now that `C-Space` *is* the prefix.
- Hardcoded paths to `~/git/ops-internal/...`, `~/git/netbox/...` etc. in the
  sessionizer binds: consider generating these from a list in Nix so the
  config doesn't rot when repos move.

### 9. `sensibleOnTop = false;` looks backwards
`programs.tmux.sensibleOnTop` defaults to `true` and puts
`tmux-sensible`'s options *before* your `extraConfig`, so your overrides win.
Setting it to `false` means `tmux-sensible`'s defaults may clobber your
conf. If that's intentional, add a comment; otherwise remove the option.

### 10. `programs.home-manager.enable = true;` in `packages.nix`
This is a per-user setting (it enables HM self-management) — fine, but it
belongs in the per-user files (`work.nix`/`oli.nix`) so it's applied per
homeManagerConfiguration, not shared. (In practice it's harmless since both
users share `packages.nix`, but it's conceptually per-user.)

## Low priority / nits

- `packages.nix`: remove the leftover `#######################` separator
  comments and the commented-out `hello` example block — they're from the
  HM template and add noise.
- `packages.nix`: `#ripgrep` — ripgrep is in nixpkgs; enable it or delete
  the line.
- `packages.nix`: consider `programs.bat`/`programs.lazygit` etc. where
  HM offers module config; and `kubectl`/`k9s`/`helm` could be grouped under
  a `# Kubernetes` comment instead of mixed in.
- `flake.nix`: `system = "x86_64-linux"` is hardcoded. You can make it
  dynamic: `system = builtins.currentSystem;` (or accept a `--system`
  override) so the flake works if you ever target ARM.
- `flake.lock` shows nixpkgs `nixpkgs-unstable` at a 2026 rev while the README
  still documents `home.stateVersion = 25.05`-era setup steps and the
  `home-manager` *channel* install (`nix-channel ... release-25.05.tar.gz`).
  You're using flakes now — update the README to just say
  `home-manager switch --flake .#oliverkelly` and drop the channel steps.
- `work.nix` has `stateVersion = "26.05"`, `oli.nix` has `"26.11"` — fine that
  they differ per user, but the README's "Updating" section says to bump
  `home.stateVersion` on flake update; that's only needed when the HM release
  actually bumps it. Consider clarifying.
- `etc/nix/nix.conf`: `experimental-features = nix-command flakes` — fine, but
  you may also want `auto-allocate-uids` if you're on a multi-user box, and
  consider `keep-outputs`/`keep-derivations` settings for GC.
- There's an untracked `.env` file in the repo root (a device node,
  `crw-rw-rw- 1 nobody nogroup 1, 3` — looks like a symlink/copy of `/dev/null`
  or similar). Whatever it is, it should be in `.gitignore` or removed; there
  is no `.gitignore` in the repo.
- Consider adding a `justfile` or Makefile with the common commands
  (`update`, `switch`, `gc`) instead of putting them in the README.
