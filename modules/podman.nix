{ pkgs, ... }:
{
  # Set up podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Install any helper programs you need.
  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  # Set up the podrick user to keep these services running.
  users.users.podrick = {
    isNormalUser = true;
    description = "Isolated Podman user";
    extraGroups = [
      "podman"
    ];
    linger = true;

    # Setup UID/GID to ensure container roots are outside normal range
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  # Mount the containers directory on the NFS to the podrick user.
  fileSystems = {
    "/home/podrick/containers" = {
      device = "/mnt/containers/libraries";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/mnt/containers" ];
    };
  };
}
