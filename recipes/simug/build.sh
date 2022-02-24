#!/bin/bash

mkdir -p "${PREFIX}/bin"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|' simuG.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|' vcf2model.pl

cp simuG.pl "${PREFIX}/bin/simuG"
cp vcf2model.pl "${PREFIX}/bin/vcf2model"
