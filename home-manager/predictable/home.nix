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
    ytdl = "yt-dlp -f 'bv[ext=mp4]+ba[ext=m4a]/bv+ba/b' --merge-output-format mp4";
  };

  home.packages = with pkgs; [
    alloy6
    elan
    unstable.claude-code
    unstable.claude-code-acp
    iterm2
    nerd-fonts.meslo-lg
    slack
    obsidian
    spotify
    pandoc
    tailscale
    texliveSmall
    gh
    ffmpeg
    yt-dlp
    uv
    cvc5
    nodejs_24
  ];

  programs = {
    git.settings.user.signingKey = "B7EB5E85D6C99135";

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
