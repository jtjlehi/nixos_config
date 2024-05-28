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
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    host = system: host_config: nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = import nixpkgs {inherit system;};
      specialArgs = inputs;
      modules = [
        ./configuration.nix
	host_config
	home-manager.nixosModules.home-manager {
	  home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;
	  home-manager.users."yajj" = import ./home;
	}
      ];
    };
    # system = "aarch64-linux";
  in {
    # nixos configurations
    nixosConfigurations.pewtermind = host "x86_64-linux" ./pewtermind.nix;
    # nixosConfigurations.pewtermind = nixpkgs.lib.nixosSystem {
    #   system = "aarch64-linux";
    #   pkgs = import nixpkgs {inherit system;};
    #   specialArgs = inputs;
    #   modules = [./configuration.nix];
    # };
    nixosConfigurations.coppermind = host "aarch64-linux" ./asahi-config.nix;
 #    nixpkgs.lib.nixosSystem {
 #      system = "aarch64-linux";
 #      pkgs = import nixpkgs {inherit system;};
 #      specialArgs = inputs;
 #      modules = [./configuration.nix];
 #    };
    # home configurations
    homeConfigurations."yajj" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        # inherit system;
        overlays = [
          inputs.apple-silicon.overlays.apple-silicon-overlay
          (final: prev: {mesa = final.mesa-asahi-edge;})
        ];
      };
      extraSpecialArgs = {inherit inputs;};
      modules = [
        ./home
      ];
    };
  };
}
