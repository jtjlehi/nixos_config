{
  description = "Root flake for coppermind-nix-asahi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    stylix,
    ...
  } @ inputs: let
    host = system: host_config:
      nixpkgs.lib.nixosSystem {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            (final: prev: {
              zjstatus = zjstatus.packages.${prev.system}.default;
            })
          ];
        };
        specialArgs = inputs;
        modules = [
          ./configuration.nix
          host_config
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."yajj" = import ./home;
          }
          stylix.nixosModules.stylix
        ];
      };
  in {
    nixosConfigurations.pewtermind = host "x86_64-linux" ./pewtermind.nix;
    nixosConfigurations.coppermind = host "aarch64-linux" ./coppermind.nix;
  };
}
