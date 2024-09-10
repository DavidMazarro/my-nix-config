# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "david";
  homeDirectory = "/home/${username}";
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

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

  home = {
    inherit username;
    inherit homeDirectory;
  };

  # Dotfiles setup
  home.file = {
    # Helix dotfiles
    "${homeDirectory}/.config/helix".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/nixos-config/dotfiles/helix";
  };

  # Zsh config
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      # plugins = [
      #   "command-not-found"
      #   "poetry"
      # ];
      theme = "agnoster";
    };
  };

  home.shellAliases = {
    ls = "lsd";
    lsl = "lsd -l";
    lsa = "lsd -a";
    lsla = "lsd -la";

    nhos = "nh os switch ${homeDirectory}/nixos-config";
    nhhome = "nh home switch ${homeDirectory}/nixos-config";
    # Removes old generations and rebuilds NixOS (to remove them from the boot entries)
    gcold = "sudo nix-collect-garbage -d && nh os switch ${homeDirectory}/nixos-config";

    nhclean = "nh clean all";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; let
    helixDeps = [
      # See: https://github.com/helix-editor/helix/wiki/Troubleshooting#on-linux
      # For X11 support of clipboard copy
      xclip
      # For Wayland support of clipboard copy
      wl-clipboard
    ];
    haskellPkgs = [
      cabal-install
      stack
      ghc
      haskell-language-server
      haskellPackages.implicit-hie
    ];
    rustPkgs = [
      rustc
      cargo
      rust-analyzer
    ];
  in
    [
      nh
      lsd
      comma
      nerdfonts
      neofetch
      obsidian
      discord
      vscode
      terminator
      google-chrome
      spotify
      firefox
      mpv
      veracrypt
      gthumb
      telegram-desktop
      # Nix code formatter
      alejandra
      # Nix LSP
      nil
      age
      yazi
      zellij
      fzf
    ]
    ++ helixDeps
    ++ haskellPkgs
    ++ rustPkgs;

  # Enable home-manager
  programs.home-manager.enable = true;

  # Git config
  programs.git = {
    enable = true;

    userName = "DavidMazarro";
    userEmail = "davidmazarro98@gmail.com";

    extraConfig = {
      user.signingKey = "7A97A25DC69A60E8";
      init.defaultBranch = "main";
      commit.gpgSign = true;
      core.editor = "vim";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
