{ pkgs, lib, ... }: {
  programs.kitty = {
    enable = true;
    font = lib.mkForce {
      package = pkgs.monaspace;
      name = "Monaspace Radon Var";
      size = 10;
    };
  };
}
