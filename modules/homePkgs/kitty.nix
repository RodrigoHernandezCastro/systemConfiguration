{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    font = {
      package = pkgs.monaspace;
      name = "Monaspace Radon Var";
      size = 10;
    };
  };
}
