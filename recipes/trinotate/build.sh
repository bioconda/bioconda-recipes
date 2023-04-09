#!/bin/bash

mkdir -p perl-build/scripts

mv util/generate_Trinotate_report.txt util/generate_Trinotate_report.sh
mv util/auto_Trinotate.txt util/auto_Trinotate.sh

cp -rf PerlLib perl-build/lib
cp -rf PerlLib ${PREFIX}/bin
cp -rf testing ${PREFIX}/trinotate-testing

find . -name "*.pl" | grep -v testing | xargs -I {} cp -rf {} perl-build/scripts/
cp Trinotate perl-build/scripts
cp Trinotate ${PREFIX}/bin

cd perl-build

cp ${RECIPE_DIR}/Build.PL ./

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

chmod u+rwx ${PREFIX}/bin/*
