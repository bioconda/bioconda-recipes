#!/bin/sh

cp -r $SRC_DIR/src/*.jl $PREFIX/bin
cp -r $SRC_DIR/scripts $PREFIX
ln -s $PREFIX/bin/MentaLiST.jl $PREFIX/bin/mentalist
chmod +x $PREFIX/bin/mentalist

julia -e 'Pkg.init()'
julia -e 'Pkg.add("Suppressor")'
julia -e 'Pkg.add("ArgParse")'
julia -e 'Pkg.add("Bio")'
julia -e 'Pkg.add("OpenGene")'
julia -e 'Pkg.add("Logging")'
julia -e 'Pkg.add("Lumberjack")'

rm -f "$PREFIX"/share/julia/site/lib/v*/*.ji
rm -rf "$PREFIX"/share/julia/site/v*/METADATA
rm -f "$PREFIX"/share/julia/site/v*/META_BRANCH
