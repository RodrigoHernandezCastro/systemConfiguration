{
  ...
}:
{
  programs.bash = {
    enable = true;
    initExtra = "command -v fastfetch > /dev/null && fastfetch";
  };
}
