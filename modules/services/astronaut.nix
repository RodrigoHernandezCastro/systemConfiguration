{
  ...
}:
{
  flake.nixosModules.sddm-astronaut =
    {
      pkgs,
      ...
    }:
    let
      sddm-astronaut =
        (pkgs.sddm-astronaut.override {
          embeddedTheme = "japanese_aesthetic";
          themeConfig = {
            HeaderTextColor = "#d5c4a1";
            Background = "Backgrounds/your-custom-background.png";
          };
        }).overrideAttrs
          (oldAttrs: {
            installPhase = oldAttrs.installPhase + ''
              chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
              cp ${./wallpaper.png} \
                $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/your-custom-background.png
            '';
          });
    in
    {
      environment.systemPackages = [ sddm-astronaut ];

      services.displayManager.sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
        ];
        theme = "sddm-astronaut-theme";
        wayland.enable = true;
      };
    };
}
