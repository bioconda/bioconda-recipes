mkdir -p $PREFIX/bin
sed "s|^NXF_HOME=.*|NXF_HOME=$PREFIX/share/$PKG_NAME|" nextflow > $PREFIX/bin/nextflow

# Use $HOME for storing some temp files (friendlier for multiuser environments)
sed -i.bak "s|^  NXF_ASSETS=\${NXF_ASSETS:-\${NXF_HOME:-\$HOME/.nextflow}/assets}| NXF_ASSETS=\${NXF_ASSETS:=\"\$HOME/.nextflow/assets\"}|" $PREFIX/bin/nextflow
rm -f *.bak

sed -i.bak "s|NXF_LAUNCHER=\${NXF_HOME}/tmp/launcher/nextflow-\${NXF_PACK}_\${NXF_VER}/\${NXF_HOST}|NXF_LAUNCHER=\$HOME/.nextflow/tmp/launcher/nextflow-\${NXF_PACK}_\${NXF_VER}/\${NXF_HOST}|" $PREFIX/bin/nextflow
rm -f *.bak

sed -i.bak "s|^CAPSULE_CACHE_DIR=\${CAPSULE_CACHE_DIR:=\"\$NXF_HOME/capsule\"}|CAPSULE_CACHE_DIR=\${CAPSULE_CACHE_DIR:=\"\$HOME/.nextflow/capsule\"}|" $PREFIX/bin/nextflow
rm -f *.bak

sed -i.bak "s|^JAVA_KEY=\"\$NXF_HOME/|JAVA_KEY=\"\$HOME/.nextflow/|" $PREFIX/bin/nextflow
rm -f *.bak

chmod 755 $PREFIX/bin/nextflow
$PREFIX/bin/nextflow -download
