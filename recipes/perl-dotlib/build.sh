#!/bin/bash

mkdir -p perl-build/
#mv *.pl perl-build           #Alternately , use find -name "*.pl" 
mv dotlib/*.pm perl-build/    #Alternately, use find -name "*.pm"
cp ${RECIPE_DIR}/Build.PL perl-build

cd perl-build

perl ./Build.PL
./Build manifest
./Build install --installdirs site
