{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "cecile";
  sops.defaultSopsFile = ../secrets/cecile.yaml;
  services.dendrite.settings.global.server_name = "furiosa.org";
}
