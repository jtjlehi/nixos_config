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
    mkSharedDir = config: path: {
      source = ''"$HOME"/${path}'';
      target = "${config.users.users.yajj.home}/${path}";
    };
    vmModule = vm: {config, ...}:
      if vm
      then {
        virtualisation.vmVariant.virtualisation.sharedDirectories = {
          nixos-config = mkSharedDir config ".dotfiles/nixos";
        };
      }
      else {};

    host = system: {
      name,
      vm ? false,
    }:
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
        specialArgs =
          inputs
          // (
            if vm
            then {
              inherit mkSharedDir;
            }
            else {}
          );
        modules = [
          ./configuration.nix
          (./. + "/${name}.nix")
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."yajj" = import ./home;
          }
          {
            networking.hostName = name;
          }
          stylix.nixosModules.stylix
          (vmModule vm)
        ];
      };
    aarchHost = host "aarch64-linux";
    x86Host = host "x86_64-linux";
  in {
    nixosConfigurations.ironmind = x86Host {name = "ironmind";};
    nixosConfigurations.pewtermind = x86Host {name = "pewtermind";};
    nixosConfigurations.aluminiummind = x86Host {
      name = "aluminiummind";
      vm = true;
    };
    nixosConfigurations.coppermind = aarchHost {name = "coppermind";};
  };
}
