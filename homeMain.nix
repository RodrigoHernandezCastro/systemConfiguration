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

    users.randy =
      { pkgs, config, ... }:
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

        gtk = {
          enable = true;
          gtk4.theme = config.gtk.theme;
        };

        imports =
          lib.filesystem.listFilesRecursive ./homePkgs
          ++ lib.filesystem.listFilesRecursive ./niri/utils
          ++ [
            inputs.willowispll.homeModules.waybar
            inputs.willowispll.homeModules.spicetify
            inputs.willowispll.homeModules.nixcord
            inputs.willowispll.homeModules.kitty
            inputs.willowispll.homeModules.fastfetch
            inputs.willowispll.homeModules.bash
            inputs.willowispll.homeModules.glide
          ];
      };
  };
}
