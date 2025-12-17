{
  description = "Root flake for coppermind-nix-asahi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
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
    security-flake = {
      url = "git+ssh://git@ghe.anduril.dev/infosec/security-flake?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      stylix,
      rust-overlay,
      nix-darwin,
      ...
    }@inputs:
    let
      overlays = with inputs; [
        (final: prev: {
          zjstatus = zjstatus.packages.${prev.system}.default;
        })
        (import rust-overlay)
      ];

      # used to setup home manager
      hm-setup =
        entry:
        { config, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${config.username} = import entry;
        };

      # gets the modules associated with home manager
      #
      # hm-modules ::
      #   {
      #     modules :: "nixosModules" | "darwinModules",
      #     entry ? ./home/default.nix :: file,
      #   } -> [Modules]
      hm-modules =
        {
          modules,
          entry ? ./home/default.nix,
        }:
        [
          home-manager.${modules}.home-manager
          (hm-setup entry)
          stylix.${modules}.stylix
          ./styling
        ];

      # the module for the configuration with given name
      #
      # if there isn't any specific config, it returns an empty list
      hostConfigModule =
        name:
        let
          path = (./. + "/${name}.nix");
        in
        nixpkgs.lib.optional (builtins.pathExists path) path;

      # shared configurations for all hosts
      hostSystem =
        {
          name,
          username,
          system,
          extraModules,
        }:
        {
          inherit system;
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
          modules = [
            ./configuration.nix
            { inherit name username; }
          ]
          ++ hostConfigModule name
          ++ extraModules;
        };
      linuxHost =
        {
          name,
          username ? "yajj",
          system,
          extraModules ? [ ],
          hmEntry ? ./home/linux.nix,
        }:
        nixpkgs.lib.nixosSystem (hostSystem {
          inherit name username system;
          extraModules = [
            ./linux
          ]
          ++ hm-modules {
            modules = "nixosModules";
            entry = hmEntry;
          }
          ++ extraModules;
        });

      darwinHost =
        {
          name,
          username ? "jtjlehi",
          extraModules ? [ ],
          useHM ? true,
        }:
        nix-darwin.lib.darwinSystem (hostSystem {
          inherit name username;
          system = "aarch64-darwin";
          extraModules = [
            ./darwin.nix
          ]
          ++ nixpkgs.lib.optional useHM (hm-modules {
            modules = "darwinModules";
            entry = ./home/default.nix;
          })
          ++ extraModules;
        });

      # build all the hosts using the provided `buildHost` function
      buildHosts =
        buildHost: hosts:
        builtins.listToAttrs (
          builtins.map (
            { name, ... }@args:
            {
              inherit name;
              value = buildHost args;
            }
          ) hosts
        );

      mapPlatforms =
        platforms: f:
        builtins.listToAttrs (
          builtins.map (platform: {
            name = platform;
            value = f platform;
          }) platforms
        );
      mapAllPlatforms = mapPlatforms [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      nixosConfigurations = buildHosts linuxHost [
        {
          name = "ironmind";
          system = "x86_64-linux";
          extraModules = [ inputs.security-flake.nixosModules.default ];
        }
        {
          name = "pewtermind";
          system = "x86_64-linux";
        }
        {
          name = "coppermind";
          system = "aarch64-linux";
        }
        {
          name = "aluminiummind";
          system = "aarch64-linux";
          username = "jjacobson";
          hmEntry = ./home/default.nix;
        }
      ];
      darwinConfigurations = buildHosts darwinHost [
        {
          name = "Jareds-MacBook-Pro";
        }
        {
          name = "steelmind";
          username = "jjacobson";
          useHM = false;
        }
      ];
      formatter = mapAllPlatforms (platform: nixpkgs.legacyPackages.${platform}.nixfmt-tree);

      apps = mapAllPlatforms (system:
        let pkgs = nixpkgs.legacyPackages.${system};
            buildScript = { name, script }: {
              inherit name;
              value = {
                type = "app";
                program = pkgs.lib.getExe (pkgs.writeShellScriptBin name script);
              };
            };
            buildScripts = scripts: builtins.listToAttrs (builtins.map buildScript scripts);
        in buildScripts [
          {
            name = "link-dotfiles";
            script = ''
              for child in ${./extra-config}/*; do
                if [ -d $child ]; then
                  ln -si "$child" "$HOME/.config"
                fi
              done
            '';
          }
        ]);
    };
}
