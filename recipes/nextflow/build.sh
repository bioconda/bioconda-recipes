mkdir -p $PREFIX/bin
sed "s|^NXF_DIST=.*|NXF_DIST=$PREFIX/share/$PKG_NAME/dist|" nextflow > $PREFIX/bin/nextflow
sed -i.bak "s|^CAPSULE_CACHE_DIR=.*|CAPSULE_CACHE_DIR=\${CAPSULE_CACHE_DIR:=$PREFIX/share/$PKG_NAME/capsule}|" $PREFIX/bin/nextflow
rm -f *.bak

chmod 755 $PREFIX/bin/nextflow
$PREFIX/bin/nextflow -download
