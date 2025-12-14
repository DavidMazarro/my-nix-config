# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
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
    flake = {
      setFlakeRegistry = false;
      setNixPath = false;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    package = pkgs.nixVersions.latest;
    settings = {
      # Enable Nix store optimization
      auto-optimise-store = true;
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  boot.supportedFilesystems = ["ntfs"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # This prevents a buzzing sound when no audio is playing.
  boot.kernelParams = ["snd_hda_intel.power_save=0"];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable the X11 windowing system and GNOME.
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
    desktopManager.gnome.enable = true;
    videoDrivers = ["nvidia"];

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "intl";
    # xkb.options = "eurosign:e,caps:escape";
  };

  # Enable picom compositor to avoid flickering and graphics weirdness.
  services.picom.enable = true;

  # Fixes Electron and Chromium apps in Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Nvidia drivers settings.
  hardware.nvidia = {
    # The actual drivers.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Enables open source drivers, recommended for RTX cards.
    open = true;
    # Modesetting is REQUIRED (apparently).
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Helps avoid screen tearing issues.
    forceFullCompositionPipeline = true;

    # Nvidia settings menu available through 'nvidia-settings' command.
    nvidiaSettings = true;
  };

  # Audio settings
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  hardware.pulseaudio.enable = false;

  # GPG settings
  programs.gnupg.agent = {
    enable = true;
  };

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
    package = pkgs.unstable.steam;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # User and host settings
  networking.hostName = "yorha";

  users = {
    mutableUsers = false;
    users."david" = {
      isNormalUser = true;
      home = "/home/david";
      description = "David Mazarro";
      shell = pkgs.zsh;
      extraGroups = ["wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
      # openssh.authorizedKeys.keys  = [ "ssh-dss AAAAB3Nza... alice@foobar" ];
      hashedPassword = "$6$gQEjZ4ihu/HElD8f$aC1HzlwKQACDR2/KgAEk.PWeV7JJdb.znKZWW1QGV5H2zrVj0XxH74j0RWlj18xBTSDgHkPvXH2HL4NVCNX.30";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gcc
    openssl
    clang
    git
    unstable.helix
    emacs
    vim
    home-manager
    wget
    gdk-pixbuf
    (writeTextFile {
      name = "raw-embedded-jpeg-thumbnailer";
      destination = "/share/thumbnailers/raw-embedded-jpeg.thumbnailer";
      text = ''
        [Thumbnailer Entry]
        TryExec=gdk-pixbuf-thumbnailer
        Exec=gdk-pixbuf-thumbnailer -s %s %u %o
        MimeType=image/x-adobe-dng;image/x-dng;image/x-nikon-nef;image/x-olympus-orf;
      '';
    })
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
