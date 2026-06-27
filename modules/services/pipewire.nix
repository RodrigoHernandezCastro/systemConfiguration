{
  ...
}:
{
  flake.nixosModules.pipewire =
    {
      pkgs,
      ...
    }:
    let
      # Archivo de configuración aislado con sintaxis nativa de PipeWire.
      # Usar pkgs.writeText evita los problemas de serialización de Nix.
      deepfilter-conf = pkgs.writeText "deepfilter-source.conf" ''
        context.modules = [
          {
            name = libpipewire-module-filter-chain
            args = {
              node.description = "Micrófono Limpio (DeepFilterNet)"
              media.name = "DeepFilterNet Mic"
              filter.graph = {
                nodes = [
                  {
                    type = ladspa
                    name = "DeepFilter"
                    plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so"
                    label = deep_filter_mono
                    control = {
                      "Attenuation Limit (dB)" = 100.0
                    }
                  }
                ]
              }
              audio.rate = 48000
              audio.position = [ FL ]
              capture.props = {
                node.name = "capture.deepfilter"
                node.passive = true
                audio.rate = 48000
              }
              playback.props = {
                node.name = "deep_filter_source"
                media.class = Audio/Source
                audio.rate = 48000
              }
            }
          }
        ]
      '';
    in
    {
      environment.systemPackages = [ pkgs.deepfilternet ];

      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      systemd.user.services.deepfilternet-source = {
        description = "DeepFilterNet PipeWire Virtual Source";
        requires = [ "pipewire.service" ];
        after = [ "pipewire.service" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.pipewire}/bin/pipewire -c ${deepfilter-conf}";
          Restart = "on-failure";
          RestartSec = "3";
        };
      };
    };
}
