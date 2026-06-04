{ lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };

    sharedModules = [
      inputs.nixcord.homeModules.nixcord
    ];

    users.randy =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home.username = "randy";
        home.homeDirectory = "/home/randy";
        home.stateVersion = "25.11";

        home.packages = with pkgs; [
          virt-manager
          virt-viewer
          spice
          spice-gtk
          spice-protocol
        ];

        gtk.enable = true;

        programs.nixcord = {
          enable = true;
          discord.enable = false;
          discord.vencord.enable = false;
          vesktop.enable = true;

          config = {
            disableMinSize = true;
            themeLinks = [
              "https://raw.githubusercontent.com/refact0r/system24/refs/heads/main/theme/flavors/system24-catppuccin-mocha.theme.css"
            ];
            plugins = {
              crashHandler.enable = true;
              showHiddenChannels.enable = true;
            };
          };
        };

        imports =
          lib.filesystem.listFilesRecursive ./homePkgs
          ++ lib.filesystem.listFilesRecursive ./niri/utils
          ++ [
            inputs.willowispll.homeModules.waybar
            inputs.willowispll.homeModules.spicetify
            inputs.willowispll.homeModules.kitty
            inputs.willowispll.homeModules.fastfetch
            inputs.willowispll.homeModules.bash
            inputs.willowispll.homeModules.glide
          ];
      };
  };
}
