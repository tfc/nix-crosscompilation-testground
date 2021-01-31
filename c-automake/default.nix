{ stdenv, autoreconfHook }:

stdenv.mkDerivation {
  name = "c-automake-hello";
  src = ./.;

  nativeBuildInputs = [ autoreconfHook ];
}
