{apple-silicon, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware/asahi.nix
    # Asahi stuff
    apple-silicon.nixosModules.apple-silicon-support
  ];
  hardware.asahi = {
    withRust = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "overlay";
    peripheralFirmwareDirectory = ./asahi-firmware;
  };
  environment.sessionVariables = {
    # help GPU work with asahi
    WLR_DRM_DEVICES = "/dev/dri/card0";
  };
}
