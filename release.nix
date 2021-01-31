let
  projects = self: super: {
    buildsystem-examples = {
      c-automake-hello   = super.callPackage ./c-automake   { stdenv = self.default-stdenv; };
      cpp-automake-hello = super.callPackage ./cpp-automake { stdenv = self.default-stdenv; };
      cpp-cmake-hello   = super.callPackage  ./cpp-cmake    { stdenv = self.default-stdenv; };
    };
  };

  gccStdenv      = self: super: { default-stdenv = self.makeStatic self.stdenv; };
  clangStdenv    = self: super: { default-stdenv = self.makeStatic self.llvmPackages_11.stdenv; };
  clangCxxStdenv = self: super: { default-stdenv = self.makeStatic self.llvmPackages_11.libcxxStdenv; };

  combinations = pkgs.lib.cartesianProductOfSets {
    stdenvSet = [
      { name = "gcc";         overlay = gccStdenv; }
      { name = "clang";       overlay = clangStdenv; }
      { name = "clanglibcxx"; overlay = clangCxxStdenv; }
    ];
    pkgsSet = [
      { name = "pkgs";                 extract = p: p; }
      { name = "pkgsMusl";             extract = p: p.pkgsMusl; }
      { name = "pkgsCrossAarch64";     extract = p: p.pkgsCross.aarch64-multiplatform; }
      { name = "pkgsCrossAarch64Musl"; extract = p: p.pkgsCross.aarch64-multiplatform-musl; }
      { name = "pkgsCrossMingw";       extract = p: p.pkgsCross.mingwW64; }
    ];
    staticSet = [
      { name = "dynamic"; overlay = self: super: { makeStatic = s: s; }; }
      { name = "static";  overlay = self: super: { makeStatic = super.makeStaticBinaries; }; }
    ];
  };

  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { overlays = [ projects clangCxxStdenv ]; };

  subPkgs = { pkgsSet, stdenvSet, staticSet }:
    let
      pkgs = import sources.nixpkgs { overlays = [ projects stdenvSet.overlay staticSet.overlay ]; };
    in
      {
        "${pkgsSet.name}-${stdenvSet.name}-${staticSet.name}" =
          (pkgsSet.extract pkgs).buildsystem-examples;
      };
in
builtins.foldl' (l: r: l // subPkgs r) {} combinations
