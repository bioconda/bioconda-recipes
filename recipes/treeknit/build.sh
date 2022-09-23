#!/bin/sh

# Please don't do the following symlinking elsewhere. It is not nice.
# Julia packages are retrieved externally and compile things with gcc without using CC etc. env variables...
# Copied from https://github.com/bioconda/bioconda-recipes/blob/25ee215/recipes/mentalist/build.sh
ln -s "${GCC}" "${BUILD_PREFIX}/gcc"

#cp -r $SRC_DIR/src/* $PREFIX/bin/
#ln -s $PREFIX/bin/TreeKnit.jl $PREFIX/bin/treeknit
#chmod +x $PREFIX/bin/treeknit

julia --project="$SRC_DIR" -e 'import Pkg; Pkg.add("PackageCompiler"); using PackageCompiler; create_app(".", "compiled")'
cp compiled/bin/* $PREFIX/bin/
cp -r compiled/lib $PREFIX/
cp -r compiled/share $PREFIX/

ln -s $PREFIX/bin/TreeKnit $PREFIX/bin/treeknit
rm "${BUILD_PREFIX}/gcc"
