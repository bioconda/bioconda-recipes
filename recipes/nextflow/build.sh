mkdir -p $PREFIX/bin
sed "s|^NXF_DIST=.*|NXF_DIST=$PREFIX/share/$PKG_NAME/dist|" nextflow > $PREFIX/bin/nextflow
rm -f *.bak

chmod 755 $PREFIX/bin/nextflow
$PREFIX/bin/nextflow -download
