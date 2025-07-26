#!/bin/bash

# Please don't do the following symlinking elsewhere. It is not nice.
# Julia packages are retrieved externally and compile things with gcc without using CC etc. env variables...
ln -sf "${GCC}" "${BUILD_PREFIX}/gcc"

cp -rf $SRC_DIR/src/*.jl $PREFIX/bin
cp -rf $SRC_DIR/scripts $PREFIX
ln -sf $PREFIX/bin/MentaLiST.jl $PREFIX/bin/mentalist
chmod 0755 $PREFIX/bin/mentalist

julia -e 'using Pkg; Pkg.add("Distributed")'
julia -e 'using Pkg; Pkg.add("ArgParse")'
julia -e 'using Pkg; Pkg.add("BioSequences")'
julia -e 'using Pkg; Pkg.add("JSON")'
julia -e 'using Pkg; Pkg.add("DataStructures")'
julia -e 'using Pkg; Pkg.add("JLD")'
julia -e 'using Pkg; Pkg.add("GZip")'
julia -e 'using Pkg; Pkg.add("Blosc")'
julia -e 'using Pkg; Pkg.add("FileIO")'
julia -e 'using Pkg; Pkg.add("TextWrap")'
julia -e 'using Pkg; Pkg.add("LightXML")'
#julia -e 'using Pkg; Pkg.add("JuMP")'
# julia -e 'using Pkg; Pkg.add("Gurobi")'

rm -rf "$PREFIX"/share/julia/site/lib/v*/*.ji
rm -rf "$PREFIX"/share/julia/site/v*/METADATA
rm -rf "$PREFIX"/share/julia/site/v*/META_BRANCH

rm -rf "${BUILD_PREFIX}/gcc"
