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

  nixpkgs.overlays = [
    # Add overlays your own flake exports (from overlays and pkgs dir):
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.unstable-packages
    outputs.overlays.ss-overlays
  ];

  home = {
    username = "david.mazarro";
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
    k9s
  ];

  programs = {
    git.extraConfig.user.signingKey = "392502F209776925";
    zsh = {
      initExtra = ''
        HOMEBREW_NO_AUTO_UPDATE=1
      '';
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
}
