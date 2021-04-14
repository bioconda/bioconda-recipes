#!/bin/bash

mkdir -p $PREFIX/bin/

cp simuG.pl $PREFIX/bin/simuG
cp vcf2model.pl $PREFIX/bin/vcf2model
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/simuG
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/vcf2model
