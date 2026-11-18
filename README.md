# home-manager

Personal [Home Manager](https://nix-community.github.io/home-manager/)
configuration, managed as a Nix flake. Two users are defined:

| Flake output | User          | Home directory        |
|--------------|---------------|-----------------------|
| `oliverkelly`| `oliverkelly` | `/home/oliverkelly`   |
| `oli`        | `oli`         | `/home/oli`           |

## Layout

- `flake.nix` — flake definition; pins `nixpkgs-unstable` (via lock) and
  `home-manager` release branch.
- `packages.nix` — shared packages and app modules (imported by both users).
- `work.nix` / `oli.nix` — per-user `home.username`, `home.homeDirectory`,
  `home.stateVersion`.
- `apps/tmux.nix`, `apps/neovim.nix` — app-specific Home Manager modules.
- `dotfiles/tmux.conf` — raw tmux config, included via `extraConfig`.
- `etc/nix/nix.conf` — reference Nix settings to copy into `/etc/nix/nix.conf`.
- `justfile` — common commands (`switch`, `dry-run`, `build`, `update`, `gc`).
  `just` itself is installed via Home Manager (`packages.nix`), so it is only
  available *after* the first switch.

## Setup (new machine)

1. Install [Nix](https://nixos.org/download) in single-user mode:

   ```sh
   sudo apt install curl git
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. Copy the Nix settings:

   ```sh
   sudo vi /etc/nix/nix.conf
   # add the contents of etc/nix/nix.conf from this repo
   mkdir -p /var/tmp
   ```

3. Clone the configuration:

   ```sh
   git clone https://github.com/0lzi/home-manager.git ~/.config/home-manager
   cd ~/.config/home-manager
   ```

4. Apply the configuration. On a fresh machine the `home-manager` and `just`
   binaries are **not** installed yet, so bootstrap via a nix shell that pulls
   them from the flake's own inputs (no channels needed):

   ```sh
   nix shell .#devShells.$USER.default -c home-manager switch --flake .#oliverkelly
   # or for the oli user:
   nix shell .#devShells.oli.default -c home-manager switch --flake .#oli
   ```

   The flake defines a `devShells.<system>.default` / `devShells.<user>.default`
   shell containing `home-manager` and `just`, built from the same locked
   inputs as the switch itself, so the first run is fully reproducible.

After this first switch, `home-manager` and `just` are installed for the user
and the `nix shell` wrapper is no longer needed:

```sh
home-manager switch --flake .#oliverkelly   # or .#oli
just switch                                 # same thing, via the justfile
```

## Everyday usage

Prefer the `just` task runner (installed by the config itself, see above):

```sh
just switch            # apply oliverkelly's config
just switch oli        # apply oli's config
just dry-run           # preview a switch without applying it
just build             # build the activation package only (CI-style check)
just update            # deliberately update flake inputs + switch
just gc                # collect nix store generations older than 30 days
```

Or call the commands directly:

```sh
home-manager switch --flake .#oliverkelly
home-manager switch --dry-run --flake .#oliverkelly   # preview only
nix build --impure .#homeConfigurations.oliverkelly.activationPackage
nix flake lock --update-input nixpkgs        # deliberate input update
nix-collect-garbage --delete-older-than 30d
```

## Updating

`nixpkgs` is `nixpkgs-unstable` and `home-manager` is pinned to a release
branch. Update **deliberately** — don't casually run `nix flake update`:

```sh
nix flake lock --update-input nixpkgs
nix flake lock --update-input home-manager
home-manager switch --flake .#oliverkelly
```

Commit the updated `flake.lock` so both users stay in sync.

`home.stateVersion` does **not** need to be bumped on every flake update —
only when a Home Manager release's release notes say the state version has
changed.

## Garbage collection

```sh
nix-collect-garbage --delete-older-than 30d
```

## Unfree packages

`nixpkgs.config.allowUnfreePredicate` in `packages.nix` allows only a specific
list of unfree packages (Spotify, VLC, marp-cli, pgadmin4). If you add a new
unfree package, add its name to that list — `nix eval` will tell you if
you've forgotten.
