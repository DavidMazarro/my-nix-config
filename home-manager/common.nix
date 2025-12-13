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
    # Zellij dotfiles
    "${homeDir}/.config/zellij".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDir}/my-nix-config/dotfiles/zellij";
  };

  home.shellAliases = {
    ls = "lsd";
    lsl = "lsd -l";
    lsa = "lsd -a";
    lsla = "lsd -la";

    lg = "lazygit";

    yz = "yazi";

    devflake = "nix flake init --template github:cachix/devenv";
  };

  home.packages = with pkgs; let
    fonts = [
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.symbols-only
      hasklig
      iosevka-comfy.comfy-wide
    ];
    nixPkgs = [
      # Nix code formatter
      alejandra
      comma
      # Nix LSP
      nil
      nix-index
      # Generate Nix packages from URLs
      nix-init
      # Generate Nix fetcher calls from repository URLs
      nurl
      # Create development environments easily
      unstable.devenv
    ];
    rustPkgs = [
      cargo
      rust-analyzer
      rustc
    ];
    shellPkgs = [
      curl
      fzf
      gnutar
      jq
      lazydocker
      lazygit
      lsd
      navi
      nh
      unar
      yazi
      zellij
    ];
  in
    [
      discord
      obsidian
      unstable.google-chrome
      vscode
    ]
    ++ fonts
    ++ shellPkgs
    ++ nixPkgs
    ++ rustPkgs;

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

    # Enables GPG.
    gpg.enable = true;

    # Enables nix-direnv.
    direnv.enable = true;

    # Helix editor
    helix = {
      enable = true;
      package = pkgs.unstable.helix;
      defaultEditor = true;
    };

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

      plugins = with pkgs; [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "zsh-autopair";
          src = fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d";
            hash = "sha256-3zvOgIi+q7+sTXrT+r/4v98qjeiEL4Wh64rxBYnwJvQ=";
          };
          file = "autopair.zsh";
        }
      ];

      initContent = ''
        source $HOME/.config/zsh/p10k.zsh
      '';
    };

    # A cd command that learns - easily navigate directories from the command line.
    autojump.enable = true;

    # Upgraded ctrl-r shell history search.
    mcfly = {
      enable = true;
      fzf.enable = true;
    };

    # Git config
    git = {
      enable = true;

      settings = {
        user.name = "DavidMazarro";
        user.email = "davidmazarro98@gmail.com";
        init.defaultBranch = "main";
        commit.gpgSign = true;
        core.editor = "hx";
      };
    };
  };
}
