#!/bin/sh

# Please don't do the following symlinking elsewhere. It is not nice.
# Julia packages are retrieved externally and compile things with gcc without using CC etc. env variables...
ln -s "${GCC}" "${BUILD_PREFIX}/gcc"

cp -r $SRC_DIR/src/*.jl $PREFIX/bin
cp -r $SRC_DIR/scripts $PREFIX
ln -s $PREFIX/bin/MentaLiST.jl $PREFIX/bin/mentalist
chmod +x $PREFIX/bin/mentalist

julia -e 'Pkg.init()'
julia -e 'Pkg.add("Distributed")'
julia -e 'Pkg.add("ArgParse")'
julia -e 'Pkg.add("BioSequences")'
julia -e 'Pkg.add("JSON")'
julia -e 'Pkg.add("DataStructures")'
julia -e 'Pkg.add("JLD")'
julia -e 'Pkg.add("GZip")'
julia -e 'Pkg.add("Blosc")'
julia -e 'Pkg.add("FileIO")'
julia -e 'Pkg.add("TextWrap")'
julia -e 'Pkg.add("LightXML")'
julia -e 'Pkg.add("JuMP")'
julia -e 'Pkg.add("Gurobi")'

rm -f "$PREFIX"/share/julia/site/lib/v*/*.ji
rm -rf "$PREFIX"/share/julia/site/v*/METADATA
rm -f "$PREFIX"/share/julia/site/v*/META_BRANCH

rm "${BUILD_PREFIX}/gcc"
