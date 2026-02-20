# This configuration file is used for almost every system (except the raspberry pi).
# If you want some package on every computer (ex. git), then install it here.

{ pkgs, ssh_port, user, ... }:

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
      sops
      age
      ssh-to-age
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
      ports = [ ssh_port ];
      allowSFTP = true;
    };
  };

  # Define custom systemd services.
  systemd.services."sops-decrypt@" = {
    description = "Decrypt SOPS secrets for %i";
    path = with pkgs; [ sops ssh-to-age coreutils openssh ];
    before = [ "pgadmin.service" "podman.service" ];
    after = [ "network.target" ];
    scriptArgs = "%i";
    serviceConfig =
      {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
    script = ''
      # %i is the string after the @
      USER_NAME="$1"
      SECRET_SOURCE="${../secrets}/$USER_NAME.env"
      DEST_DIR="/run/secrets/$USER_NAME"
      DEST_FILE="$DEST_DIR/secrets.env"

      KEY_FILE="/run/secrets/decryption_key.txt"
      mkdir -p /run/secrets
      chmod 700 /run/secrets

      mkdir -p "$DEST_DIR"
      ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > "$KEY_FILE"
      chmod 600 "$KEY_FILE"

      # Use the host SSH key to decrypt
      export SOPS_AGE_KEY_FILE="$KEY_FILE"
      if sops -d "$SECRET_SOURCE" > "$DEST_FILE"; then
        echo "Decryption successful for $USER_NAME"
      else
        echo "Decryption failed for $USER_NAME"
        rm -f "$KEY_FILE"
        exit 1
      fi

      rm "$KEY_FILE"
      chown -R "$USER_NAME" "$DEST_DIR"
      chmod 700 "$DEST_DIR"
      chmod 400 "$DEST_FILE"
    '';
  };
}
