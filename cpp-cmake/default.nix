{ stdenv, cmake }:

stdenv.mkDerivation {
  name = "cpp-cmake-hello";
  src = ./.;

  nativeBuildInputs = [ cmake ];
}
