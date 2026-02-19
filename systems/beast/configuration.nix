# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Consider using a low-latency kernel if AudioGridder struggles

  # Allow other machines to pull binaries from here
  nix.settings.trusted-users = [ "nix-builder" ];

  networking.hostName = "beast"; # Define your hostname.

  users.users.nix-builder = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiz72Focj9kfZbUgau7UqkUvhOL7tIUBMl04XVaZ27/a2DmIYmPPuEXEBroaH2+OWz9dSrDiuAJCdklvQ/mjK7I5cTP20ig35yTLFMiPrbQieH+ugq4PZXJMVtiePhD+p6c/y+UsSwV3HBJhPC/bxsdSI+eCQuQM/JZ7DtKQSlOIwPqIDelaGRtaonkh+W4OWkIZ7Ix8uTfycvYLXnCXWFTBqVEuUqUvbtMK7SprLeXw1uUyfGMfQDB2iXqkoEOT54VCKUA9huqViwSlFgdQtjGnOe+v6Nw/VL3BAvHvlPNmzwSc+f2kIsSVzsqZ4JkxQlBIrLKFBjgKnL3ZvViVhbWh2SxHgXsr2tkaGscHqd8GxzBd6cPYdNUd0/mTaqjpdNYp/dN5/7BfpdMcgGsibBn3hb4LBsr3JKpb878zSqfTFz7filO5fRrgHanHCF/fu/teQ4oaAikieF7QlCFI+w0N1VUwvPhp0KFmetJqYO3+bltmv6Lxi2+X4QpvDWcSs= jacksonb@Jacksons-MacBook-Air" ];
  };

  environment = {
    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    systemPackages = with pkgs; [
      # insert-here
    ];

    shellAliases = {
      # This command rebuilds the pi system remotely. Don't use this without setting ssh
      # and remote build access to the pi first.
      rebuild-pi = ''nixos-rebuild switch --flake .#pi --target-host pi --build-host "" --sudo --ask-sudo-password --option sandbox false --option filter-syscalls false'';
    };
  };

  # List services that you want to enable:

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}

