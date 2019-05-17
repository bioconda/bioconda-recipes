#!/bin/sh

mkdir -p $PREFIX/bin

# Build all multiz binaries
make

# Give execute permissions to binaries
chmod +x all_bz
chmod +x lav2maf
chmod +x pair2tb
chmod +x single_cov2
chmod +x blastzWrapper
chmod +x maf_project
chmod +x maf2lav
chmod +x maf2fasta
chmod +x maf_order
chmod +x mafFind
chmod +x get_standard_headers
chmod +x maf_checkThread
chmod +x tba
chmod +x roast
chmod +x multic
chmod +x multiz
chmod +x maf_sort
chmod +x get_covered

# Move binaries to bin folder
mv all_bz $PREFIX/bin
mv lav2maf $PREFIX/bin
mv pair2tb $PREFIX/bin
mv single_cov2 $PREFIX/bin
mv blastzWrapper $PREFIX/bin
mv maf_project $PREFIX/bin
mv maf2lav $PREFIX/bin
mv maf2fasta $PREFIX/bin
mv maf_order $PREFIX/bin
mv mafFind $PREFIX/bin
mv get_standard_headers $PREFIX/bin
mv maf_checkThread $PREFIX/bin
mv tba $PREFIX/bin
mv roast $PREFIX/bin
mv multic $PREFIX/bin
mv multiz $PREFIX/bin
mv maf_sort $PREFIX/bin
mv get_covered $PREFIX/bin
