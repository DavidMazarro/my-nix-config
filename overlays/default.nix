# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # Workaround for inetutils 2.7 Darwin build failure
    # See: https://github.com/NixOS/nixpkgs/issues/488689
    inetutils = prev.inetutils.overrideAttrs (old: {
      hardeningDisable = (old.hardeningDisable or []) ++ ["format"];
    });
  };

  ss-overlays = import ./ss-overlays.nix;

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "google-chrome-144.0.7559.97"
        ];
      };
    };
  };
}
