{
  description = "Master flake for my homelab configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, neovim-nightly-overlay, ... }:
    let
      # Just enter your details here and they will be applied across machines.
      user = {
        name = "jacksonb";
        email = "distractjax@gmail.com";
        fullname = "Jackson Baker";
      };
      addresses = {
        # This is the ip or .local address of whatever machine you want to host the nfs on.
        storage = "10.0.0.83";
      };
      # This is the name of your external hard drive.
      # If you use my full config, I highly recommend formatting the hard drive as btrfs
      # and making sure that your external drive for your raspberry pi and your external drive
      # for your storage machine have the same name (check this with "lsblk -f"). 
      # This will also make it easy to swap them out if the storage drive becomes corrupted.
      data_drive = "external_data";

      specialArgs = inputs // {
        inherit
          addresses
          data_drive
          user;
      };
    in
    {
      # This exports a NixOS module
      nixosConfigurations = {
        "beast" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./systems/common.nix
            ./systems/beast/configuration.nix
            ./systems/beast/hardware-configuration.nix
            ./modules/neovim.nix
            ./modules/nfs-mnt.nix
          ];
        };
        "pods1" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./systems/common.nix
            ./systems/pods1/configuration.nix
            ./systems/pods1/hardware-configuration.nix
            ./modules/neovim.nix
            ./modules/podman.nix
            ./modules/nfs-mnt.nix
          ];
        };
        "pods2" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./systems/common.nix
            ./systems/pods2/configuration.nix
            ./systems/pods2/hardware-configuration.nix
            ./modules/neovim.nix
            ./modules/podman.nix
            ./modules/nfs-mnt.nix
          ];
        };
        "pi" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [
            ./systems/raspberry-pi/configuration.nix
            ./systems/raspberry-pi/hardware-configuration.nix
            ./modules/postgresql.nix
            ./modules/podman.nix
          ];
        };
        "storage" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./systems/common.nix
            ./systems/storage/configuration.nix
            ./systems/storage/hardware-configuration.nix
            ./modules/neovim.nix
            ./modules/postgresql.nix
          ];
        };
      };

      templates = {
        python = {
          path = ./templates/python;
          description = "A simple Python development environment";
          welcomeText = ''
            # Welcome to Python!
            Run 'direnv allow' to enable direnv for this folder.
            Run 'git init' to create a Git repository.
          '';
        };

        javascript = {
          path = ./templates/javascript;
          description = "A simple Javascript development environment";
          welcomeText = ''
            # Welcome to Javascript!
            Run 'direnv allow' to enable direnv for this folder.
            Run 'git init' to create a Git repository.
          '';
        };

        # Define a default template
        default = self.templates.python;
      };
    };
}
