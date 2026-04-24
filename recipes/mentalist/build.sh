#!/bin/bash

# Please don't do the following symlinking elsewhere. It is not nice.
# Julia packages are retrieved externally and compile things with gcc without using CC etc. env variables...
ln -s "${CC}" "${BUILD_PREFIX}/gcc"

cp -r $SRC_DIR/src/*.jl $PREFIX/bin
cp -r $SRC_DIR/scripts $PREFIX
ln -s $PREFIX/bin/MentaLiST.jl $PREFIX/bin/mentalist
chmod +x $PREFIX/bin/mentalist

julia --threads ${CPU_COUNT} -e 'using Pkg; Pkg.develop(path="src/"); using MentaLiST'

#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("Distributed")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("ArgParse")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("BioSequences")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("JSON")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("JLD")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("DataStructures")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("GZip")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("Blosc")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("FileIO")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("TextWrap")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("LightXML")';
#"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.instantiate()';

rm -f "$PREFIX"/share/julia/site/lib/v*/*.ji
rm -rf "$PREFIX"/share/julia/site/v*/METADATA
rm -f "$PREFIX"/share/julia/site/v*/META_BRANCH

rm "${BUILD_PREFIX}/gcc"
