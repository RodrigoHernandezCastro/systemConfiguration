{
  ...
}:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.randy = {
    isNormalUser = true;
    description = "Randy";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "docker"
      "libvirtd"
      "kvm"
      "audio"
    ];
  };
}
