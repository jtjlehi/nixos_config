{
  pkgs,
  options,
  lib,
  config,
  ...
}: {
    users.users.jtjlehi = {
      home = "/Users/jtjlehi";
      name = "jtjlehi";
    };
}
