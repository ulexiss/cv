{
  secrets ? import ./secrets.nix,
  pkgs ? import (builtins.fetchTarball {
    name = "nixos-unstable-2019-12-05";
    url =  https://github.com/nixos/nixpkgs/archive/cc6cf0a96a627e678ffc996a8f9d1416200d6c81.tar.gz;
    sha256 = "1srjikizp8ip4h42x7kr4qf00lxcp1l8zp6h0r1ddfdyw8gv9001";
  }) {}
}: with pkgs;

  let
    name = "ulexiss-cv";

    secrectsAsList = lib.mapAttrsToList (name: value: ''!!!${name}!!! ${value}'') (lib.mapAttrs (name: value: lib.escapeShellArg value) secrets);

    patchScript = lib.foldl (a: b: a + ''substituteInPlace ${name}.tex --replace ${b}'' + "\n") "" secrectsAsList;

    derivationParams = {
      name = name;

      src = ./src;

      buildInputs = [
        (texlive.combine {
          inherit (texlive)
            scheme-medium
            newenviron
            catoptions
            xstring
            lastpage
            libertine
            curve
            mweights
            fontaxes
            pbox
            needspace
            fontawesome
            realboxes
            tcolorbox
            environ
            trimspaces
            forloop
            collectbox
            cv4tw;
        })
        glibcLocales
      ];

      postPatch = patchScript;

      buildPhase = ''
        export TEXMFVAR=$(pwd)

        lualatex -interaction=nonstopmode $name.tex
        lualatex -interaction=nonstopmode $name.tex
      '';

      installPhase = ''
        mkdir -p $out

        cp $name.log $out
        cp $name.pdf $out
      '';
    };
  in
    stdenv.mkDerivation (derivationParams // secrets)
