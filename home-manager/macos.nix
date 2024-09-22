{
  config,
  pkgs,
  ...
}: let
  username = "dmunuera";
  homeDirectory = "/Users/${username}";
  common = import ./common.nix {inherit config pkgs;};
in {
  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  home = {
    inherit username;
    inherit homeDirectory;
  };

  home.packages = with pkgs;
    common.home.packages
    ++ [
      hello
    ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
