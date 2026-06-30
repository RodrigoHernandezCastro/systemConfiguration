{
  flake.nixosModules.translator = {
    imports = [ ../customModules/packages/translator.nix ];
  };
}
