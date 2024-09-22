{
  config,
  pkgs,
  outputs,
  ...
}: {
  home.packages = with pkgs; [
    lsd
    yazi
    zellij
    fzf
    navi
    # Nix code formatter
    alejandra
    # Nix LSP
    nil
    direnv
    lazygit
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

  programs.zsh = {
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
      theme = "agnoster";
    };
  };
}
