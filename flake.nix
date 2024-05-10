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

  outputs = { nixpkgs, home-manager, apple-silicon, ... }@inputs:
    let
      system = "aarch64-linux";
    in {
      nixosConfigurations.coppermind-nix-asahi = nixpkgs.lib.nixosSystem {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
        specialArgs = inputs;
        modules = [ ./configuration.nix ];
      };
      homeConfigurations."yajj" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            apple-silicon.overlays.apple-silicon-overlay
            (final: prev: { mesa = final.mesa-asahi-edge; })
          ];
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
