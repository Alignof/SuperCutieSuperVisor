{
  description = "ARM + RISC-V bare metal OS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          toolchain = fenix.packages.${system}.fromToolchainFile {
            file = ./rust-toolchain.toml;
            sha256 = "sha256-mvUGEOHYJpn3ikC5hckneuGixaC+yGrkMM/liDIDgoU=";
          };
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = [
              toolchain
              pkgs.cargo-binutils  # cargo objcopy / objdump / nm
              pkgs.qemu            # qemu-system-aarch64, qemu-system-riscv64
              pkgs.gdb             # multiarch debugger
            ];
          };
        }
      );
    };
}
