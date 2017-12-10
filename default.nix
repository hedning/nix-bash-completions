with import <nixpkgs> {}; stdenv.mkDerivation rec {
  name = "nix-bash-completions";
  src = ./.;
  installPhase = ''
    commands=$(
      function complete() { shift 2; echo "$@"; }
      shopt -s extglob
      source _nix
    )
    install -Dm444 -t $out/share/bash-completion/completions _nix
    cd $out/share/bash-completion/completions
    for c in $commands; do
      ln -s _nix $c
    done
  '';
}
