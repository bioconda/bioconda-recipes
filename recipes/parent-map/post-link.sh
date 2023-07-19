#!/bin/sh
echo "#!/bin/sh
python -m $PKG_NAME \$@
" >  $CONDA_PREFIX/bin/$PKG_NAME
chmod +x $CONDA_PREFIX/bin/$PKG_NAME
