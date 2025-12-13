final: prev: let
  # Import the nixpkgs version specific for kustomize_4
  kustomizeSpecificNixpkgs =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/42c5e250a8a9162c3e962c78a4c393c5ac369093.tar.gz";
      sha256 = "y5Mcf0MDz+KB3JU+ywVKUc0elt3CX+HHL2LE/5eqae0=";
    }) {
      system = final.stdenv.hostPlatform.system;
      config = final.config;
    };
in {
  kustomize-overlay = {
    kustomize_4 = kustomizeSpecificNixpkgs.kustomize_4; # Version 4.5.7
  };
}
