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

  home.shellAliases = {
    alloy = "alloy6";
    sortphotos = ''
      mkdir -p RAW JPG \
      && find . -maxdepth 1 -type f \( -iname "*.orf" -o -iname "*.nef" \) -exec mv -n {} RAW/ \; \
      && find . -maxdepth 1 -type f -iname "*.jpg" -exec mv -n "{}" JPG/ \; \
      && for f in RAW/* JPG/*; do
        [ -f "$f" ] || continue
        created=$(GetFileInfo -d "$f")
        SetFile -m "$created" "$f"
      done
    '';
  };

  home.packages = with pkgs; [
    alloy6
    unstable.claude-code
    iterm2
  ];

  programs = {
    zsh = {
      initContent = ''
        PATH="$HOME/.cabal/bin:$HOME/.local/bin:$HOME/.ghcup/bin:$PATH"
      '';
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";
}
