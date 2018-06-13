#!/bin/bash


mkdir -p perl-build/lib
cp ${RECIPE_DIR}/Build.PL perl-build
find . -name "*.pl" | xargs -I {} cp {} perl-build
find . -name "*.pm" | xargs -I {} cp {} perl-build/lib
cd perl-build
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..



mkdir -p $PREFIX/bin

./waf configure --prefix=$PREFIX/bin
./waf build
./waf install



