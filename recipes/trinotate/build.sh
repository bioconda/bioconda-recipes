#!/bin/bash

mkdir -p perl-build/scripts

mv util/generate_Trinotate_report.txt util/generate_Trinotate_report.sh
mv util/auto_Trinotate.txt util/auto_Trinotate.sh

cp -rf PerlLib perl-build/lib
cp -rf sample_data ${PREFIX}/trinotate-sample-data

find . -name "*.pl" | grep -v sample_data | xargs -I {} cp -rf {} perl-build/scripts/
cp Trinotate perl-build/scripts

cd perl-build

cp ${RECIPE_DIR}/Build.PL ./

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

chmod u+rwx $PREFIX/bin/*
