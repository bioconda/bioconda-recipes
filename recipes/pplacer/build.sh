#!/bin/bash
mkdir -p $PREFIX/bin

if [ "$(uname -m)" = "aarch64" ]; then
    OPAM_URL="https://github.com/ocaml/opam/releases/download/2.2.1/opam-2.2.1-arm64-linux"
else
    OPAM_URL="https://github.com/ocaml/opam/releases/download/2.2.1/opam-2.2.1-x86_64-linux"
fi

curl -L $OPAM_URL -o $PREFIX/bin/opam && chmod +x $PREFIX/bin/opam

export OPAMYES=1
opam init --disable-sandboxing -y --compiler=5.2.1
eval $(opam env)

opam repo add pplacer-deps http://matsen.github.io/pplacer-opam-repository
opam update || true 

opam install -y \
    dune \
    csv \
    ounit2 \
    xmlm \
    batteries \
    gsl \
    sqlite3 \
    camlzip \
    ocamlfind

git clone https://github.com/fhcrc/mcl.git -b config-fix-and-ocaml5
cd mcl
./configure
make -j
cd ..

dune build

cp _build/install/default/bin/guppy $PREFIX/bin
cp _build/install/default/bin/pplacer $PREFIX/bin
cp _build/install/default/bin/rppr $PREFIX/bin

chmod +x $PREFIX/bin/{guppy,pplacer,rppr}
