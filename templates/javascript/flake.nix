{
  description = "A basic javascript dev flake";

  # Inputs: where to get packages from
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Define the systems you want to support
      allSystems = [
        "x86_64-linux" #64-bit Intel/AMD Linux
        "x86_64-darwin" #64-bit Intel/AMD Mac
        "aarch64-linux" # Apple Silicon Linux
        "aarch64-darwin" # Apple Silicon Mac
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          # Packages to include in the environment
          packages = with pkgs; [
            # Runtime and package manager
            nodejs_24 # For legacy options
            bun # The new hotness (Fast, Test-runner, Bundler)

            # LSPs and Tooling
            typescript-language-server
            markdownlint-cli

            # Userful Utilities
            http-server
          ];
          # Shell commands to run upon activation
          shellHook = ''
            echo "Entering the development environment..."
          '';
        };
      });
    };
}
