{pkgs, ...}: {
  imports = [
    ./python.nix
  ];
  environment.systemPackages = with pkgs; [
    git
    gh
    ripgrep
    nushell
    zsh
    pulseaudio
    bear
    unzip
    valgrind
    bat
    perf
    # plotting and diagrams and visuals and stuff
    gnuplot
    eog
    # typst and stuff
    typst
    tinymist
    # podman/docker
    podman-tui
    podman-compose
  ];
}
