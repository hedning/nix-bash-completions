with import <nixpkgs> {}; stdenv.mkDerivation rec {
  name = "nix-bash-completions";
  src = ./.;
  installPhase = ''
    mkdir -p $out/share/bash-completion/completions
    cp _nix $out/share/bash-completion/completions
  '';
}
