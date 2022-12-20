{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    ./matrix
  ];

  services.openssh.enable = true;
  programs.mosh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  users.users.luxus = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups =
      [
        "wheel"
        "video"
        "audio"
      ]
      ++ ifTheyExist [
        "network"
        "wireshark"
        "i2c"
        "mysql"
        "docker"
        "podman"
        "git"
        "libvirtd"
        "deluge"
      ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/AjBtg8D4lMoBkp2L3dDb5EmkOGr1v/Ns1wwRoKds4"
    ];
    # passwordFile = config.sops.secrets.luxus-password.path;
    initialHashedPassword = "$y$j9T$Ih/tbi7qNN/.1QD9wIctw1$Ea701spnW1tbG4JFCJPWV6f.cW6vINStsEasErah3M0";
  };
  users.users.root = {
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/AjBtg8D4lMoBkp2L3dDb5EmkOGr1v/Ns1wwRoKds4"
    ];
    # passwordFile = config.sops.secrets.root-password.path;
    initialHashedPassword = "$y$j9T$Ih/tbi7qNN/.1QD9wIctw1$Ea701spnW1tbG4JFCJPWV6f.cW6vINStsEasErah3M0";
  };
  # environment.persistence."/persistent" = {
  #   files = [
  #     "/etc/machine-id"
  #     "/etc/ssh/ssh_host_ed25519_key"
  #     "/etc/ssh/ssh_host_ed25519_key.pub"
  #     "/etc/ssh/ssh_host_rsa_key"
  #     "/etc/ssh/ssh_host_rsa_key.pub"
  #   ];
  # };
  environment.systemPackages = [
    pkgs.git
    pkgs.comma
    pkgs.nix-index
  ];

  sops = {
    age = {
      sshKeyPaths = ["/persistent/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };

  system.stateVersion = "22.05";
}
