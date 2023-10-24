#!/bin/bash

BINARY=mummer
BINARY_HOME=$PREFIX/bin
MUMMER_HOME=$PREFIX/opt/mummer-$PKG_VERSION

mkdir -p $BINARY_HOME
mkdir -p $MUMMER_HOME

# cd to location of Makefile and source
cp -R $SRC_DIR/* $MUMMER_HOME

cd $MUMMER_HOME

# One of the Makefiles references a shell script not in the path
export PATH="$PATH:."
make CC=$CC CXX=$CXX CPPFLAGS="-O3 -DSIXTYFOURBITS"

binaries="\
combineMUMs \
delta-filter \
dnadiff \
exact-tandems \
mapview \
mgaps \
mummer \
mummerplot \
nucmer \
promer \
repeat-match \
run-mummer1 \
run-mummer3 \
show-aligns \
show-coords \
show-diff \
show-snps \
show-tiling \
"

# patch defined(%hash) out
# https://github.com/bioconda/bioconda-recipes/issues/1254

perl -i -pe 's/defined \(%/\(%/' mummerplot

#Fix escaping symbol @ included in the path to the library (mainly for conda virtual env with galaxy)
for i in exact-tandems dnadiff mapview mummerplot nucmer promer run-mummer1 run-mummer3; do
  perl -i -pe 's/(envs\/\_\_.*)(\K\@)/\\@/' $i
done

for i in $binaries; do 
  chmod +x $MUMMER_HOME/$i
  ln -s "$MUMMER_HOME/$i" "$BINARY_HOME/$i"
done

# clean up
find $MUMMER_HOME -name *.o -exec rm -f {} \;
