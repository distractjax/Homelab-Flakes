{ config, pkgs, ... }:

{
  # Add an overlay to pull packages from the unstable channel
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
        config = {
			  allowUnfree = prev.config.allowUnfree;
			};
      };
    })
  ];

	environment.systemPackages = with pkgs; [
		htop
		wget
		git
		lua
		tmux
		gnumake
		ripgrep
		unzip
		zip
		gcc
		fd
		nixd
		bash-language-server
		lua-language-server

		# Unstable
		unstable.neovim
	];
}
