{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.python3.withPackages (ps: [
      ps.ruff
      ps.matplotlib
      ps.numpy
    ]))
  ];
}
