{
  config,
  pkgs,
  outputs,
  ...
}: let
  username = "dmunuera";
  homeDirectory = "/Users/${username}";
  common = import ./common.nix {inherit config pkgs outputs homeDirectory;};
in {
  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  home = {
    inherit username;
    inherit homeDirectory;
  };

  home.file = common.home.file;

  home.shellAliases = common.home.shellAliases;

  home.packages = with pkgs;
    common.home.packages
    ++ [
      hello
    ];

  nixpkgs = common.nixpkgs;

  programs = common.programs;
  
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
}
