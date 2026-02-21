{ pkgs, user, data_drive, ... }:
{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "jacksonb" ]; # This enables the beast system to be used as a remote builder.

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    supportedFilesystems = [ "btrfs" "nfs" ];
  };

  fileSystems = {
    "/mnt/data_drive" = {
      device = "/dev/disk/by-label/${data_drive}";
      fsType = "btrfs";
      options = [ "noatime" ];
    };
  };

  environment = {
    enableAllTerminfo = true;
    systemPackages = with pkgs; [
      vim
      htop
      wget
      parted
      btrfs-progs
    ];
  };

  networking = {
    hostName = "raspberry";
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 3000 3001 8384 ];
      allowedUDPPorts = [ ];
      checkReversePath = "loose";
    };
    nftables.enable = true;
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "${user.fullname}";
        email = "${user.email}";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  services = {
    openssh = {
      enable = true;
      ports = [ 51364 ];
      allowSFTP = true;
    };

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };

  # Set up swap devices
  zramSwap.enable = true;

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 2048;
  }];

  # Set up a user account. Don't forget to set a new password with 'passwd'.
  users.users."${user.name}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "26.05";
}
