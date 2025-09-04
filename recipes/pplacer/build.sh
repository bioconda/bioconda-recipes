#!/bin/sh
set -e -x
mkdir -p $PREFIX/bin
if [ "$(uname)" = "Darwin" ] ; then
    for i in guppy pplacer rppr ; do
             chmod +x $i
             install_name_tool -change /opt/homebrew/opt/gsl/lib/libgsl.28.dylib "${PREFIX}/lib/libgsl.28.dylib" "${i}"
             cp $i ${PREFIX}/bin
    done
             
else
    OCAML_VERSION=4.14.2

    # Initialize opam with specified OCaml version
    opam init --disable-sandboxing -y --compiler=${OCAML_VERSION} \
        && eval $(opam env)

    # Add pplacer opam repository
    eval $(opam env) && opam repo add pplacer-deps http://matsen.github.io/pplacer-opam-repository && opam update



    eval $(opam env) \
         opam install --assume-depexts -y \
         dune.3.19.1 \
         csv.2.4 \
         ounit2.2.2.7 \
         xmlm.1.4.0 \
         batteries.3.8.0 \
         gsl.1.25.0 \
         sqlite3.5.2.0 \
         camlzip.1.11 \
         ocamlfind; \


    cd mcl
    eval $(opam env) \
        && ./configure \
        && make
    eval $(opam env)
    echo "Checking MCL libraries..." \
        && ls -la src/clew/libclew.a \
        && ls -la src/impala/libimpala.a \
        && ls -la src/mcl/libmcl.a \
        && ls -la util/libutil.a \
        && echo "All MCL libraries built successfully!"

    cd ..
    # Build pplacer
    eval $(opam env) \
        && dune build

    cd _build/default

    for i in guppy pplacer rppr ; do
        cp $i.exe $PREFIX/bin
        ln -s $PREFIX/bin/$i.exe $PREFIX/bin/$i
    done                                 
fi
