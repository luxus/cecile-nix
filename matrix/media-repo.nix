{ config, ... }:

let
  inherit (config.services.dendrite.settings.global) server_name;
in
  {
    imports = [
      ./nginx.nix
      ./postgresql.nix
    ];

    services = {
      postgresql = {
        ensureUsers = [
          {
            name = "matrix-media-repo";
            ensurePermissions = {
              "DATABASE \"matrix-media-repo\"" = "ALL PRIVILEGES";
            };
          }
        ];

        ensureDatabases = [ "matrix-media-repo" ];
      };

      matrix-media-repo = {
        enable = true;
        environmentFile = "/run/secrets/matrix-media-repo/environment_file";
        settings = {
          homeservers = [
            {
              name = server_name;
              csApi = "https://${server_name}/";
            }
          ];
          database.postgres = "postgresql:///matrix-media-repo?host=/run/postgresql";
          datastores = [
            {
              type = "s3";
              opts = {
                tempPath = "";
                endpoint = "storage.de.cloud.ovh.net/v1/AUTH_64c351d16d1f4731973b63256f2ac8cc";
                accessKeyId = "$ACCESS_KEY_ID";
                accessSecret = "$ACCESS_SECRET";
                ssl = true;
                bucketName = "chat";
              };
            }
          ];
          # "defaults" aren't actually properly default... remove this at some point?
          # https://github.com/turt2live/matrix-media-repo/blob/bfb7d8d7399252b0bf1428c6429a4d16b17f2224/common/config/conf_domain.go#L68-L71
          thumbnails.types = [
            "image/jpeg"
            "image/jpg"
            "image/png"
            "image/apng"
            "image/gif"
            "image/heif"
            "image/webp"
            #"image/svg+xml" # Be sure to have ImageMagick installed to thumbnail SVG files
            "audio/mpeg"
            "audio/ogg"
            "audio/wav"
            "audio/flac"
            #"video/mp4" # Be sure to have ffmpeg installed to thumbnail video files
          ];
        };
      };

      nginx.virtualHosts."${server_name}".locations."/_matrix/media".proxyPass = "http://127.0.0.1:8000";
    };

    systemd.services.matrix-media-repo = {
      wants = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };

    sops.secrets."matrix-media-repo/environment_file" = {};
  }
