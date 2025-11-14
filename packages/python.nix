{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.python3.withPackages (ps: [
      ps.python-lsp-server
      ps.matplotlib
      ps.numpy
    ]))
  ];
}

