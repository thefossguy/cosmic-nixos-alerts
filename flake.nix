{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      cosmicTests = lib.genAttrs systems (
        system:
        lib.filterAttrs (
          _: test:
          let
            ms = test.meta.maintainers or [ ];
          in
          lib.subtractLists lib.teams.cosmic.members ms == [ ]
          && lib.subtractLists ms lib.teams.cosmic.members == [ ]
        ) nixpkgs.legacyPackages.${system}.nixosTests
      );

      cosmicPkgs = lib.genAttrs systems (
        system:
        lib.filterAttrs (
          _: pkg:
          let
            r = builtins.tryEval (builtins.elem lib.teams.cosmic (pkg.meta.teams or [ ]));
          in
          r.success && r.value
        ) nixpkgs.legacyPackages.${system}
      );
    };
}
