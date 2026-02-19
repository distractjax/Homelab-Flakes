{ addresses, user, ... }:
{
  # NFS File Share
  services.rpcbind.enable = true;
  fileSystems = {
    "/mnt/storage" = {
      device = "${addresses.storage}:/export/storage";
      fsType = "nfs";
      options = [ "x-systemd.automount" "nfsvers=3" "noauto" ];
    };
    "/mnt/containers" = {
      device = "${addresses.storage}:/export/containers";
      fsType = "nfs";
      options = [ "auto" "nfsvers=3" "rw" "nolock" "soft" "noatime" ];
    };
    "/mnt/config" = {
      device = "${addresses.storage}:/export/config";
      fsType = "nfs";
      options = [ "auto" "nfsvers=3" ];
    };
    "/home/${user.name}/.config" = {
      device = "/mnt/config";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/mnt/config" ];
    };
  };
}
