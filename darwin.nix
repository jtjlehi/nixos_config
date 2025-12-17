{
  config,
  ...
}:
let
  username = config.username;
in
{
  users.users.${username} = {
    home = "/Users/${username}";
    name = username;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
}
