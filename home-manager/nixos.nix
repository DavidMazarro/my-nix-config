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
  common = import ./common.nix {inherit config pkgs outputs homeDirectory;};
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

  nixpkgs = common.nixpkgs;

  home = {
    inherit username;
    inherit homeDirectory;
  };

  # Dotfiles setup
  home.file = common.home.file // {
    # Terminator dotfiles
    "${homeDirectory}/.config/terminator".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/my-nix-config/dotfiles/terminator";
  };

  # Zsh config
  programs.zsh = common.programs.zsh;

  home.shellAliases = common.home.shellAliases // {
    nhos = "nh os switch ${homeDirectory}/my-nix-config";
    nhhome = "nh home switch ${homeDirectory}/my-nix-config";
    # Removes old generations and rebuilds NixOS (to remove them from the boot entries)
    gcold = "sudo nix-collect-garbage -d && nh os switch ${homeDirectory}/my-nix-config";  
    nhclean = "nh clean all";
    ytdl = "yt-dlp -f 'bv+ba/b' --merge-output-format mp4";
  };
  
  # GNOME / GTK settings

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    # These two disable automatic turning off screen after period of inactivity.
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      last-selected-power-profile = "performance";

      favorite-apps = [
        "google-chrome.desktop"
        "discord.desktop"
        "org.telegram.desktop.desktop"
        "code.desktop"
        "terminator.desktop"
        "org.gnome.Music.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Settings.desktop"
      ];
      # `gnome-extensions list` for a list
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
      ];
    };

    # Extension-specific settings.
    # Since these come from dconf, to find out the name for
    # a specific option, run `dconf watch /` and change any option
    # manually and its name will show up along its current value.
    "org/gnome/shell/extensions/dash-to-dock" = {
      dash-max-icon-size = 64;
      scroll-action = "cycle-windows";
      click-action = "minimize";
    };
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
    gnomeExts = [
      gnomeExtensions.dash-to-dock
    ];
    fonts = [
      hasklig
    ];
  in
    common.home.packages
    ++ [
      nh
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
      age
      yt-dlp
      unstable.gallery-dl
      ntfs3g
      syncplay
      qdirstat
      testdisk
    ]
    ++ helixDeps
    ++ haskellPkgs
    ++ rustPkgs
    ++ gnomeExts
    ++ fonts;

  # Enable home-manager
  programs.home-manager.enable = true;

  # Git config
  programs.git = {
    enable = true;

    userName = "DavidMazarro";
    userEmail = "davidmazarro98@gmail.com";

    extraConfig = {
      user.signingKey = "8A58E16D54BC2304E889DBF7387EE9CB2E5CA73A";
      init.defaultBranch = "main";
      commit.gpgSign = true;
      core.editor = "hx";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}