{
  config,
  pkgs,
  outputs,
  ...
}: {
  home.file = let
    homeDir = config.home.homeDirectory;
  in {
    # Zsh dotfiles
    "${homeDir}/.config/zsh".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDir}/my-nix-config/dotfiles/zsh";
    # Helix dotfiles
    "${homeDir}/.config/helix".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDir}/my-nix-config/dotfiles/helix";
  };

  home.shellAliases = {
    ls = "lsd";
    lsl = "lsd -l";
    lsa = "lsd -a";
    lsla = "lsd -la";

    lg = "lazygit";

    yz = "yazi";
  };

  home.packages = with pkgs; let
    fonts = [
      nerdfonts
      hasklig
      iosevka-comfy.comfy-wide
    ];
    nixPkgs = [       
      comma
      nix-index
      # Nix LSP
      nil
      # Nix code formatter
      alejandra
    ];
    rustPkgs = [
      rustc
      cargo
      rust-analyzer
    ];
    haskellPkgs = [
      cabal-install
      stack
      ghc
      haskell-language-server
      haskellPackages.implicit-hie
    ];
  in
    [
      unstable.helix
      nh
      lsd
      yazi
      zellij
      fzf
      navi
      lazygit
      google-chrome
      obsidian
      discord
      vscode
    ]
    ++ fonts
    ++ nixPkgs
    ++ rustPkgs
    ++ haskellPkgs;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  programs = {
    # Enable home-manager and let it manage itself.
    home-manager.enable = true;

    # Enables nix-direnv.
    direnv.enable = true;

    # Zsh config
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        # plugins = [
        #   "command-not-found"
        #   "poetry"
        # ];
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

      initExtra = ''
        source $HOME/.config/zsh/p10k.zsh
      '';
    };

    # Git config
    git = {
      enable = true;

      userName = "DavidMazarro";
      userEmail = "davidmazarro98@gmail.com";

      extraConfig = {
        init.defaultBranch = "main";
        commit.gpgSign = true;
        core.editor = "hx";
      };
    };
  };
}
