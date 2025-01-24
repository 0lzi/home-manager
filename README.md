# home-manager

- Set up Ubuntu as usual.
- Install `home-manager`
- sudo apt install curl git
- sh <(curl -L https://nixos.org/nix/install) --daemon
- sudo apt install git
- nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
- nix-channel --update
- nix-shell '<home-manager>' -A install
- rm -rf .config/home-manager/
- git clone https://github.com/0lzi/home-manager.git
- cd home-manager/
- sudo vi /etc/nix/nix.conf 
- add
```
experimental-features = nix-command flakes
```
- home-manager switch --flake .#oliverkelly

## Updating

```
Update home-manager version
nix flake update
home-manager switch --flake .#oliverkelly
```

## Garbage collection

```
nix-collect-garbage --delete-older-than 30d

```
