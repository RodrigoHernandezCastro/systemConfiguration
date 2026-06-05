{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.kokorotts;
in
{
  options = {
    services.kokorotts = {
      enable = lib.mkEnableOption "TTS for reading outloud text";
      package = lib.mkPackageOption pkgs [ "haskellPackages" "kokoro-tts" ] { };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.kokorotts = {
      description = "Kokoro TTS FastAPI Server";
      after = [
        "network.target"
        "docker.service"
      ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        ${pkgs.docker}/bin/docker rm -f kokoro-fastapi 2>/dev/null || true
        ${pkgs.docker}/bin/docker run --rm \
          -p 8880:8880 \
          --name kokoro-fastapi \
          ghcr.io/remsky/kokoro-fastapi-cpu:latest
      '';

      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
