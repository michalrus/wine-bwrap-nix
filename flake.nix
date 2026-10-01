{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = inputs: {
    packages =
      inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: rec {
        default = wine-bwrap;
        wine-bwrap = inputs.nixpkgs.legacyPackages.${system}.callPackage ./default.nix {};
      });
  };
}
