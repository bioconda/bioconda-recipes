mkdir -p $PREFIX/bin
chmod 755 nextflow
cp nextflow $PREFIX/bin
$PREFIX/bin/nextflow -download
