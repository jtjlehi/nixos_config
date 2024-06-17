{...}: {
  imports = [hardware/iron.nix];
  environment.etc."kolide-k2/secret" = {
    mode = "0600";
    text = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmdhbml6YXRpb24iOiJuYW1hemUiLCJraWQiOiJiODoxZDowNjo5NzpjYjo3OTpjMDo3MTpjNDoxNTpjZDo5Yzo4Mjo0MDo4NjpjYSIsImNyZWF0ZWRBdCI6IjE3MTA1MzA4MzgiLCJjcmVhdGVkQnkiOiJrd29ya2VyIn0.ye25D-ty23UeK1zO8p1G1cSqYB3E-VHp3N38nTjMQ3zWx_T6-b3h-cBPnSUmrL7wXblytxR2cmOq0rBkdnpaxolpSLCnMw3Iccd4w2q1Shev0wq3WXUQrxhvUi-MkFKS6HtvXVfffnDxM_LSuFraqXnA1KigH8byFnQi4RaGzSR1ZRtWwcJGVDO3uBfBEZgZKM28pg3aOpQ0YrzuBRktq6hl0rPS1ecd00p7m6LNJIhujPiToakDjMm0AmEYqRJRWTeQmivl1LqucpM3Xn-sJM9c7uDuK-xgi0O0-Z-GhUPna7GoV1FT0V5OveNVdg548e1eoc8ozaOc5sjxzJStAg";
  };
  services.kolide-launcher.enable = true;
}
