# This configuration file is used for almost every system (except the raspberry pi).
# If you want some package on every computer (ex. git), then install it here.

{ pkgs, user, ... }:

{
  # Enable nix command and flakes
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
      persistent = true;
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "${user.name}" ]; # This allows user.name to run nixos-rebuild
    };
  };

  # Use the systemd EFI boot loader for all modern UEFI devices.
  # This boot loader section is one of the big reasons that the pi doesn't use this
  # module, since it uses a custom boot loader.
  boot = {
    kernel.sysctl."vm-swappiness" = 10; # Don't use swap unless RAM is 90% full.
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # This is for the NFS storage system and the systems that mount it.
    # I thought it'd just be convenient for everyone to have access so
    # it doesn't get forgotten when a new machine is added.
    supportedFilesystems = [ "nfs" "btrfs" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${user.name}" = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable 'sudo' for the user.
      "nogroup"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment = {
    enableAllTerminfo = true;
    systemPackages = with pkgs; [
      openssl
      wget
      htop
      parted
      btrfs-progs
    ];
  };

  # Enable your program modules here.
  programs = {
    git = {
      enable = true;
      config = {
        user = {
          name = "${user.fullname}";
          email = "${user.email}";
        };
        init.defaultBranch = "main";
      };
    };
    starship.enable = true;
  };

  # List services that you want to enable:

  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      ports = [ 51364 ];
      allowSFTP = true;
    };
  };
}

