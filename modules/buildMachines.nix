{
  nix.buildMachines = [
    {
      hostName = "nix-builder";
      system = "x86_64-linux"; # Match the remote architecture
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  programs.ssh.extraConfig = ''
    		Host nix-builder
    			HostName 10.0.0.119
    			User nix-builder
    			IdentityFile /root/.ssh/id_rsa
    			StrictHostKeyChecking accept-new
    	'';
  nix.settings.builders-use-substitutes = true;
}
