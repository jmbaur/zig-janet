{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = inputs: {
    devShells.x86_64-linux.default = inputs.nixpkgs.legacyPackages.x86_64-linux.callPackage (
      { mkShell, zig_0_15 }: mkShell { packages = [ zig_0_15 ]; }
    ) { };
  };
}
