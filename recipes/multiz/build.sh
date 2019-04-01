#!/bin/sh

mkdir -p $PREFIX/bin

# Build all multiz binaries
make

# Give execute permissions to binaries
chmod +x src/all_bz
chmod +x src/lav2maf
chmod +x src/pair2tb
chmod +x src/single_cov2
chmod +x src/blastzWrapper
chmod +x src/maf_project
chmod +x src/maf2lav
chmod +x src/maf2fasta
chmod +x src/maf_order
chmod +x src/mafFind
chmod +x src/get_standard_headers
chmod +x src/maf_checkThread
chmod +x src/tba
chmod +x src/roast
chmod +x src/multic
chmod +x src/multiz
chmod +x src/maf_sort
chmod +x src/get_covered

# Move binaries to bin folder
mv src/all_bz $PREFIX/bin
mv src/lav2maf $PREFIX/bin
mv src/pair2tb $PREFIX/bin
mv src/single_cov2 $PREFIX/bin
mv src/blastzWrapper $PREFIX/bin
mv src/maf_project $PREFIX/bin
mv src/maf2lav $PREFIX/bin
mv src/maf2fasta $PREFIX/bin
mv src/maf_order $PREFIX/bin
mv src/mafFind $PREFIX/bin
mv src/get_standard_headers $PREFIX/bin
mv src/maf_checkThread $PREFIX/bin
mv src/tba $PREFIX/bin
mv src/roast $PREFIX/bin
mv src/multic $PREFIX/bin
mv src/multiz $PREFIX/bin
mv src/maf_sort $PREFIX/bin
mv src/get_covered $PREFIX/bin
