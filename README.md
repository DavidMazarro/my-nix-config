# My NixOS / home-manager config + dotfiles
## Set up on a fresh NixOS
First, clone this repository (preferrably, under `$HOME/nixos-config`).
After that, from within the root of the repository, run the following command
to build NixOS from the config:
```
sudo nixos-rebuild switch --flake .#yorha
```
Then, you can build the home configuration with the following command:
```
home-manager switch --flake .#david@yorha
```
After this initial set up, the aliases `nhos` and `nhhome` can be used from
any location to rebuild NixOS and the home configuration respectively.
