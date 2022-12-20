{config, lib,  pkgs, ... }:
{
 services.signald.enable = true;
  systemd.services.matrix-as-signal = {
    requires = [ "signald.service" ];
    after = [ "signald.service" ];
    unitConfig = {
      JoinsNamespaceOf = "signald.service";
    };
    path = [
      pkgs.ffmpeg # voice messages need `ffmpeg`
    ];
  };

  services.matrix-appservices = {
    addRegistrationFiles = true;
    services = {
      # imessage = {
      #   port = 29184;
      #   format = "mautrix-go";
      #   package = pkgs.mautrix-imessage;
      # };
      # discord = {
      #   port = 29184;
      #   format = "mautrix-go";
      #   package = pkgs.mautrix-discord;
      # };
      signal = {
        port = 29185;
        format = "mautrix-go";
        package = pkgs.mautrix-signal;
        serviceConfig = {
          StateDirectory = [ "matrix-as-signal" "signald" ];
          SupplementaryGroups = [ "signald" ];
        };
        settings.signal = {
          socket_path = config.services.signald.socketPath;
          outgoing_attachment_dir = "/var/lib/signald/tmp";
        };
        settings.homeserver.domain = "luxus.ai";
        settings.homeserver.address = "https://luxus.ai";
      };
      whatsapp = {
        port = 29183;
        format = "mautrix-go";
        package = pkgs.mautrix-whatsapp;
        settings.homeserver.domain = "luxus.ai";
        settings.homeserver.address = "https://luxus.ai";
      };
    };
  };
}
