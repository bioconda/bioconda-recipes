#!/bin/sh

# Please don't do the following symlinking elsewhere. It is not nice.
# Julia packages are retrieved externally and compile things with gcc without using CC etc. env variables...
ln -s "${GCC}" "${BUILD_PREFIX}/gcc"

cp -r $SRC_DIR/src/*.jl $PREFIX/bin
cp -r $SRC_DIR/scripts $PREFIX
ln -s $PREFIX/bin/MentaLiST.jl $PREFIX/bin/mentalist
chmod +x $PREFIX/bin/mentalist

julia -e 'Pkg.init()'
#julia -e 'Pkg.add("Bio")'
#julia -e 'Pkg.add("OpenGene")'
#julia -e 'Pkg.add("Logging")'
#julia -e 'Pkg.add("Lumberjack")'
julia -e 'using Pkg; Pkg.add([ "Distributed", "ArgParse", "BioSequences", "JSON", "DataStructures", "JLD", "GZip", "Blosc", "FileIO", "TextWrap", "LightXML", "JuMP", "Gurobi"])'

rm -f "$PREFIX"/share/julia/site/lib/v*/*.ji
rm -rf "$PREFIX"/share/julia/site/v*/METADATA
rm -f "$PREFIX"/share/julia/site/v*/META_BRANCH

rm "${BUILD_PREFIX}/gcc"
