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
    users.randy = {
      home.username = "randy";
      home.homeDirectory = "/home/randy";
      home.stateVersion = "25.11";

      imports =
        lib.filesystem.listFilesRecursive ./homePkgs
        ++ lib.filesystem.listFilesRecursive ./niri/utils
        ++ [
          inputs.willowispll.homeModules.waybar
          inputs.willowispll.homeModules.spicetify
        ];
    };
  };
}
