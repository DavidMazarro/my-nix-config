{
  config,
  pkgs,
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
}
