#!/bin/sh

# circumvent a bug in conda-build >=2.1.18,<3.0.10
# https://github.com/conda/conda-build/issues/2255
[[ -z $REQUESTS_CA_BUNDLE && ${REQUESTS_CA_BUNDLE+x} ]] && unset REQUESTS_CA_BUNDLE
[[ -z $SSL_CERT_FILE && ${SSL_CERT_FILE+x} ]] && unset SSL_CERT_FILE

cp -r $SRC_DIR/src/*.jl $PREFIX/bin
cp -r $SRC_DIR/scripts $PREFIX
ln -s $PREFIX/bin/MentaLiST.jl $PREFIX/bin/mentalist
chmod +x $PREFIX/bin/mentalist

julia -e 'Pkg.init()'
julia -e 'Pkg.add("ArgParse")'
julia -e 'Pkg.add("Bio")'
julia -e 'Pkg.add("OpenGene")'
julia -e 'Pkg.add("Logging")'
julia -e 'Pkg.add("Lumberjack")'
julia -e 'Pkg.add("FastaIO")'
julia -e 'Pkg.add("JLD")'
julia -e 'Pkg.add("DataStructures")'

rm -f "$PREFIX"/share/julia/site/lib/v*/*.ji
rm -rf "$PREFIX"/share/julia/site/v*/METADATA
rm -f "$PREFIX"/share/julia/site/v*/META_BRANCH
