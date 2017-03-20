#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin
#cp -r * $PREFIX

# install in opt/
mkdir -p $PREFIX/opt/
cp -r $SRC_DIR $PREFIX/opt/$PKG_NAME

ln -s $PREFIX/opt/$PKG_NAME/bin/abricate $PREFIX/bin/
ln -s $PREFIX/opt/$PKG_NAME/bin/abricate-get_db $PREFIX/bin/
ln -s $PREFIX/opt/$PKG_NAME/scripts/abricate-fix_resfinder_fasta $PREFIX/bin/
ln -s $PREFIX/opt/$PKG_NAME/scripts/abricate-update_db $PREFIX/bin/
