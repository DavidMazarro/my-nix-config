# My NixOS / home-manager config + dotfiles
> [!NOTE]
> The general structure of this configuration is based on [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs).

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

## Interacting through the REPL
To play around with flake and the attribute sets, you can open a REPL by running
the following command from within the repository root folder:
```
nix repl --expr "builtins.getFlake \"$PWD\""
```
Then, load the attributes provided by nixpkgs:
```
:l <nixpkgs>
```
Finally, you can import any of the modules by passing it the necessary arguments:
```
common = import ./home-manager/common.nix {inherit config outputs; pkgs = homeConfigurations."david@yorha".pkgs;}
```

## Common issues
### error: path '/nix/store/\<hash\>-source/\<some file>.nix' does not exist
This can happen if you have created a new file and tried to perform a `nixos-rebuild` or `home-manager` command without first staging that file in Git. Always remember to stage files before rebuilding!
