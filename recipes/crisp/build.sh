#!/bin/bash
sed -i.bak '0,/LIBPATH=/d' samtools/Makefile
export LIBPATH=$PREFIX/lib/
make all
cp bin/CRISP-genotypes $PREFIX/bin/
cp bin/CRISPindel $PREFIX/bin/
chmod +x $PREFIX/bin/CRISP-genotypes
chmod +x $PREFIX/bin/CRISPindel