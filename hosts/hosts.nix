[
  {
    host = "nixos";
    user = "setsuna";
    extraOSModules = [ ./setsuna/os.nix ];
    extraHomeModules = [ ./setsuna/home.nix ];
    extraHomeArgs = {
      nixosVersion = "unstable";
      homeManagerVersion = "master";
    };
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBYuZfKN1dkbkpWudyH/v8a25OrF2LfsjNe1+J0FgWa";
  }
]
