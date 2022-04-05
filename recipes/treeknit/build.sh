#!/bin/sh

# Please don't do the following symlinking elsewhere. It is not nice.
# Julia packages are retrieved externally and compile things with gcc without using CC etc. env variables...
# Copied from https://github.com/bioconda/bioconda-recipes/blob/25ee215/recipes/mentalist/build.sh
ln -s "${GCC}" "${BUILD_PREFIX}/gcc"

cp -r $SRC_DIR/src/* $PREFIX/bin/
ln -s $PREFIX/bin/TreeKnit.jl $PREFIX/bin/treeknit
chmod +x $PREFIX/bin/treeknit

julia -e 'using Pkg'
julia -e 'Pkg.add("TreeTools")'

rm "${BUILD_PREFIX}/gcc"
