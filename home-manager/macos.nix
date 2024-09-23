{
  config,
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./common.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  home = {
    username = "dmunuera";
    homeDirectory = "/users/${config.home.username}";
  };

  home.packages = with pkgs; [
    hello
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
}
