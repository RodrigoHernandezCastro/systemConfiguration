{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    kdePackages.filelight
    kdePackages.gwenview
    kdePackages.kate
  ];
}
