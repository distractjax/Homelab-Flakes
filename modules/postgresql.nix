{ pkgs, user, config, lib, ... }:
{
  services = {
    postgresql = {
      enable = true;
      settings.listen_addresses = pkgs.lib.mkForce "0.0.0.0";
      # List databases for whatever apps you have running here.
      ensureDatabases = [
        "mealie"
        "romm"
        "forgejo"
      ];
      # Your user names must be the same as your database names for
      # ensureDBOwnership to work.
      ensureUsers = [
        { name = "mealie"; ensureDBOwnership = true; }
        { name = "romm"; ensureDBOwnership = true; }
        { name = "forgejo"; ensureDBOwnership = true; }
      ];
      authentication = pkgs.lib.mkForce ''
        #TYPE DATABASE       USER           ADDRESS          METHOD
        local all            all                             trust
        host  all            all            127.0.0.1/32     trust
        host  mealie         mealie         10.0.0.132/24    md5
        host  romm           romm           10.0.0.132/24    md5
        host  forgejo        forgejo        10.0.0.132/24    md5
      '';
    };
    pgadmin = {
      enable = true;
      initialEmail = "${user.email}";
      # Reset your password once you have the GUI working!
      initialPasswordFile = "${../secrets/pgadmin.txt}";
      port = 5050;
      settings.DEFAULT_SERVER = "0.0.0.0";
    };
  };
  systemd.services.pgadmin = {
    environment.PGADMIN_LISTEN_ADDRESS = "0.0.0.0";
  };

  # This opens the TCP port for pgAdmin.
  networking.firewall.allowedTCPPorts = [ 5050 ];

  # # This runs the sops-decrypt service for pgadmin. (See the common file for the service).
  # systemd.targets.multi-user.wants = [ "sops-decrypt@pgadmin.service" ];
}
