#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

mkdir -p perl-build/scripts

mv util/generate_Trinotate_report.txt util/generate_Trinotate_report.sh
mv util/auto_Trinotate.txt util/auto_Trinotate.sh

cp -rf PerlLib perl-build/lib
cp -rf PerlLib ${PREFIX}/bin
cp -rf testing ${PREFIX}/trinotate-testing

find . -name "*.pl" | grep -v testing | xargs -I {} cp -rf {} perl-build/scripts/
cp Trinotate perl-build/scripts && chmod +rx perl-build/scripts/*
cp perl-build/scripts/* ${PREFIX}/bin

cd perl-build

cp ${RECIPE_DIR}/Build.PL ./

perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
