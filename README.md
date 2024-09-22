# My NixOS and home-manager config + dotfiles
> [!NOTE]
> The general structure of this configuration is based on [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs).

## Setup guide
If you plan on setting this up on macOS or another non-NixOS Linux distribution, you can [skip ahead here](#if-you-want-to-build-the-home-with-home-manager). 

### Installing NixOS (optional)
Install NixOS on a new host by following the 
[installation instructions in the NixOS manual](https://nixos.org/manual/nixos/stable/#sec-installation). 
After successfully installing NixOS, proceed to the next section.

### Setting up the system and home
Clone this repository (preferrably, under `$HOME/my-nix-config`).
After that, from within the root folder of the repository, you can:

#### If you are on NixOS and want to configure it:
First, locate the `hardware-configuration.nix` that was generated 
during the installation under `/etc/nixos/hardware-configuration.nix`,
and copy it into the [nixos](./nixos/) folder of this repository.
Rename it as desired, it will be referenced within the `configuration.nix` that you create for your current system.

After that, create a new host in the `nixosConfigurations` attribute
in [flake.nix](./flake.nix). This host will be used from now on
as an entrypoint to rebuild your current system with the specified
configuration files.

Finally, you can run the following command to rebuild NixOS from 
the config specified for your host in [flake.nix](./flake.nix):
```
sudo nixos-rebuild switch --flake ".#<host>"
```

#### If you want to build the home with `home-manager`:
First, create a new user@host in the `homeConfigurations` attribute
in [flake.nix](./flake.nix). This user@host will be used from now on
as an entrypoint to rebuild your current home with the specified `home-manager` configuration files.

After that, you can build the home configuration with the following command:
```
home-manager switch --flake ".#<user>@<host>"
```

## Interacting with attributes from the REPL
To play around with the flake and the attribute sets, you can open a REPL by running
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
This can happen if you have created a new file and tried to perform 
a `nixos-rebuild` or `home-manager` command without first staging that file in Git.
Always remember to stage files before rebuilding!
