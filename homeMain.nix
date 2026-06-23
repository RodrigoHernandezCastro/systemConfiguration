{
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs.nixpkgs.lib.fileset) toList fileFilter;
  tree =
    path:
    toList (
      fileFilter (
        file:
        if file.type == "directory" then
          true
        else
          file.hasExt "nix" && !(inputs.nixpkgs.lib.hasPrefix "_" file.name)
      ) path
    );
in
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

      gtk.enable = true;

      imports =
        tree ./homePkgs
        ++ tree ./niri/utils
        ++ [
          inputs.willowispll.homeModules.spicetify
          inputs.willowispll.homeModules.nixcord
          inputs.willowispll.homeModules.mako
        ];
    };
  };
}
