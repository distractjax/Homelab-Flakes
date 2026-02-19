{ config, pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    settings.listen_addresses = pkgs.lib.mkForce "0.0.0.0";
    ensureDatabases = [
      "mealie"
      "romm"
      "forgejo"
    ];
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
}
