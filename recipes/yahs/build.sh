mkdir -p ${PREFIX}/bin
export CFLAGS="-I$PREFIX/include -L$PREFIX/lib"
make
mv yahs ${PREFIX}/bin
mv agp_to_fasta ${PREFIX}/bin