mkdir -p $PREFIX/bin
sed "s|^NXF_HOME=.*|NXF_HOME=$PREFIX/share/$PKG_NAME|" nextflow > $PREFIX/bin/nextflow
chmod 755 $PREFIX/bin/nextflow
$PREFIX/bin/nextflow -download
