{ pkgs, neovim-nightly-overlay, ... }:
{
  nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];

  environment.systemPackages = with pkgs; [
    ripgrep
    lua
    gnumake
    unzip
    zip
    gcc
    fd
    nixd
    nixpkgs-fmt
    bash-language-server
    lua-language-server
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim;
    viAlias = true;
    vimAlias = true;
  };
}
