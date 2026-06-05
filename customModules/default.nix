let
  #programModules = builtins.mapAttrs (dir: _: ./programs/${dir}) (
  #builtins.removeAttrs (builtins.readDir ./programs) [
  #  "README.md"
  #]
  #);

  serviceModules = builtins.listToAttrs (
    map
      (file: {
        name = builtins.replaceStrings [ ".nix" ] [ "" ] file;
        value = import ./services/${file};
      })
      (
        builtins.filter (
          file: (builtins.readDir ./services).${file} == "regular" && builtins.match ".*\\.nix" file != null
        ) (builtins.attrNames (builtins.readDir ./services))
      )
  );
in
#programModules //
serviceModules
