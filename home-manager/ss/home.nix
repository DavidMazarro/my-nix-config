{
  config,
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ../common.nix
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  home = {
    username = "david";
    homeDirectory = "/Users/${config.home.username}";
  };

  # Dotfiles setup
  home.file = let
    homeDir = config.home.homeDirectory;
  in {
    # iTerm2 dotfiles
    "${homeDir}/.config/iterm2".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDir}/my-nix-config/dotfiles/iterm2";
  };

  home.packages = with pkgs; [
    iterm2
    slack
  ];

  programs = {
    git.extraConfig.user.signingKey = "39ED198C4E2C9A5B";
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
}
