#!/bin/bash

BINARY=mummer
BINARY_HOME=$PREFIX/bin
MUMMER_HOME=$PREFIX/opt/mummer-$PKG_VERSION

mkdir -p $BINARY_HOME
mkdir -p $MUMMER_HOME

sed -i.bak 's/^CC.*$//g' Makefile
sed -i.bak 's/^CXX.*$//g' Makefile
sed -i.bak 's/^AR.*$//g' Makefile
sed -i.bak 's/^PERL.*$//g' Makefile
sed -i.bak 's/^SED.*$//g' Makefile
sed -i.bak 's/^CSH.*$//g' Makefile

pushd ${PREFIX}/bin/
ln -s ./tcsh ./csh
popd

# replace perl with /usr/bin/env perl and remove -w flag
find . -name \*.pl -exec sed  -i.bak 's^/usr/bin/env perl -w^/usr/bin/env perl^' {} \;

# cd to location of Makefile and source
cp -R $SRC_DIR/* $MUMMER_HOME

cd $MUMMER_HOME

make
make check

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
cd $BINARY_HOME
for i in exact-tandems dnadiff mapview mummerplot nucmer promer run-mummer1 run-mummer3; do
  perl -i -pe 's/(envs\/\_\_.*)(\K\@)/\\@/' $i
  # replace perl with /usr/bin/env perl and remove -w flag
  # sed  -i.bak 's^/usr/bin/env perl -w^/usr/bin/env perl^' $i
done

for i in $binaries; do 
  chmod +x $MUMMER_HOME/$i
  ln -s "$MUMMER_HOME/$i" "$BINARY_HOME/$i"
done
