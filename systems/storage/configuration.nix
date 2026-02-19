# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, user, data_drive, ... }:

{
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };

    qemuGuest.enable = true;

    nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
      # anonuid and anongid are both 237 to solve file permission problems with Syncthing.
      exports = ''
        /export 10.0.0.0/8(rw,fsid=0,no_subtree_check,crossmnt)
        /export/code 10.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=237,anongid=237)
        /export/containers 10.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=237,anongid=237)
        /export/config 10.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=237,anongid=237)
        /export/storage 10.0.0.0/8(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=237,anongid=237)
      '';
    };
  };

  networking = {
    hostName = "storage"; # Define your hostname.
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        80
        111
        2049
        4000
        4001
        4002
        5432
        8384
        8443
      ];
      allowedUDPPorts = [
        111
        2049
        4000
        4001
        4002
      ];
      checkReversePath = "loose";
      trustedInterfaces = [ "inbrz0" ];
    };
    nftables.enable = true;
  };

  # Mount the storage drive and bind it
  fileSystems = {
    "/mnt/storage" = {
      device = "/dev/disk/by-label/${data_drive}";
      fsType = "btrfs";
      options = [ "defaults" "nofail" ];
    };
    "/export" = {
      device = "/mnt/storage";
      options = [ "bind" ];
    };

    # Mount your configurations
    "/home/${user.name}/.config" = {
      device = "/mnt/storage/config";
      options = [ "bind" ];
    };
  };

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

