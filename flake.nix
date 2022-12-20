{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-matrix-appservices = {
      url = "gitlab:luxus/nix-matrix-appservices";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    colmena,
    impermanence,
    sops-nix,
    nix-matrix-appservices,
    ...
  }: {
  services.geoclue2.enable = true;
  time.timeZone = "Europe/Zurich";
    nixosConfigurations = {
      cecile = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          nix-matrix-appservices.nixosModules.default
          ./cecile
          {deployment.buildOnTarget = true;}
        ];

        extraModules = [
          colmena.nixosModules.deploymentOptions
        ];
      };
    };

    colmena =
      {
        meta.nixpkgs = import nixpkgs {};
      }
      // builtins.mapAttrs (name: value: {
        nixpkgs.system = value.config.nixpkgs.system;
        imports = value._module.args.modules;
      })
      self.nixosConfigurations;

    devShells."x86_64-linux".default = import ./shell.nix {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    };
  };
}
