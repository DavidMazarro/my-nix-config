# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.spicetify-nix.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../common.nix
  ];

  home = {
    username = "david";
    homeDirectory = "/home/${config.home.username}";
  };

  # Dotfiles setup
  home.file = let
    homeDir = config.home.homeDirectory;
  in {
    # Terminator dotfiles
    "${homeDir}/.config/terminator".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDir}/my-nix-config/dotfiles/terminator";
  };

  home.shellAliases = let
    homeDir = config.home.homeDirectory;
  in {
    nhos = "nh os switch ${homeDir}/my-nix-config";
    nhhome = "nh home switch ${homeDir}/my-nix-config";
    # Removes old generations and rebuilds NixOS (to remove them from the boot entries)
    gcold = "sudo nix-collect-garbage -d && nh os switch ${homeDir}/my-nix-config";
    nhclean = "nh clean all";
    ytdl = "yt-dlp -f 'bv+ba/b' --merge-output-format mp4";
    gallery-dl-twitter = "gallery-dl --filename \"{date:%Y-%m-%d}__{user['name']}__{tweet_id}_{num}.{extension}\"";
  };

  # GNOME / GTK settings
  gtk = {
    enable = true;

    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };

    iconTheme = {
      name = "rose-pine";
      package = pkgs.rose-pine-icon-theme;
    };
  };

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-uri-dark = "file://${config.home.homeDirectory}/my-nix-config/images/Ange-Wallpaper-3440x1440.png";
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
        "steam.desktop"
        "obsidian.desktop"
        "spotify.desktop"
        "slack.desktop"
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

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = ["<Shift><Super>s"];
    };

    # Nautilus file browser settings.
    "org/gnome/nautilus/preferences" = {
      # Show image thumbnails even in remote folders.
      show-image-thumbnails = "always";
    };

    # Extension-specific settings.
    # Since these come from dconf, to find out the name for
    # a specific option, run `dconf watch /` and change any option
    # manually and its name will show up along its current value.
    "org/gnome/shell/extensions/dash-to-dock" = {
      dash-max-icon-size = 64;
      scroll-action = "cycle-windows";
      click-action = "minimize";
      custom-theme-shrink = true;
    };
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpg" = ["org.gnome.Loupe.desktop" "org.gnome.gThumb.desktop"];
        "image/png" = ["org.gnome.Loupe.desktop" "org.gnome.gThumb.desktop"];
        "video/mp4" = ["mpv.desktop" "org.gnome.Totem.desktop"];
        "application/pdf" = ["org.gnome.Evince.desktop" "google-chrome.desktop"];
      };
    };
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; let
    helixLinuxDeps = [
      # See: https://github.com/helix-editor/helix/wiki/Troubleshooting#on-linux
      # For X11 support of clipboard copy
      xclip
      # For Wayland support of clipboard copy
      wl-clipboard
    ];
    gnomeExts = [
      gnomeExtensions.dash-to-dock
    ];
  in
    [
      neofetch
      terminator
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
      slack
      racket
      unstable.vcsi
      smplayer
    ]
    ++ helixLinuxDeps
    ++ gnomeExts;

  # Spotify configuration (via Spicetify)
  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    enable = true;
    theme = spicePkgs.themes.ziro;
    colorScheme = "rose-pine-moon";
  };

  programs = {
    git.settings.user.signingKey = "AAA728A5C63AA61EC163D4458E06C34E2B1DD127";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
