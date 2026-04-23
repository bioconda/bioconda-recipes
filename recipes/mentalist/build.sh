#!/bin/sh

# Please don't do the following symlinking elsewhere. It is not nice.
# Julia packages are retrieved externally and compile things with gcc without using CC etc. env variables...
ln -s "${CC}" "${BUILD_PREFIX}/gcc"

cp -r $SRC_DIR/src/*.jl $PREFIX/bin
cp -r $SRC_DIR/scripts $PREFIX
ln -s $PREFIX/bin/MentaLiST.jl $PREFIX/bin/mentalist
chmod +x $PREFIX/bin/mentalist

"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("ArgParse")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("Bio")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("OpenGene")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("Logging")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("Lumberjack")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("FastaIO")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("JLD")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("DataStructures")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.instantiate()' >> "${PREFIX}/.messages.txt" 2>&1

rm -f "$PREFIX"/share/julia/site/lib/v*/*.ji
rm -rf "$PREFIX"/share/julia/site/v*/METADATA
rm -f "$PREFIX"/share/julia/site/v*/META_BRANCH

rm "${BUILD_PREFIX}/gcc"
