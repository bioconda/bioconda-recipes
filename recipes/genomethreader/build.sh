#!/bin/bash
mkdir -p $PREFIX/bin/{bssm,gthdata}

if [[ $target_platform == 'linux-aarch64']]; then
export CC=$CC
export CXX=$CXX
wget https://github.com/genometools/genometools/archive/refs/tags/v1.6.3.tar.gz -O genometools-1.6.3.tar.gz
tar xf genometools-1.6.3.tar.gz
mv genometools-1.6.3 genometools
cd genometools
make -j
make install
cd ../
cp -r genometools ../

wget https://github.com/genometools/vstree/archive/refs/tags/v2.3.1.tar.gz -O vstree-2.3.1.tar.gz
tar xf vstree-2.3.1.tar.gz
cd vstree-2.3.1/src
ln -snf Makedef-linux-arm Makedef

export PATH=$SRC_DIR/vstree-2.3.1/src/bin:$PATH
export WORKVSTREESRC=$SRC_DIR/vstree-2.3.1/src
sed -i '5c\CFLAGS=${WITHSYSCONF} ${DEFINECFLAGS} ${DEFINECPPFLAGS} -Wno-use-after-free' kurtz-basic/Makefile
sed -i '4c\CFLAGS=${DEFINECFLAGS} ${DEFINECPPFLAGS} ${MAINFLAGS} -Wno-format-overflow' Mkvtree/Makefile
sed -i '120c\\' Makefile
make licensemanager=no
make install
cd ../../
mv vstree-2.3.1 vstree
cp -r vstree ..

export CFLAGS="-Wno-error=unused-but-set-variable -Wno-error=format-truncation= -Wno-error=unused-function"
make licensemanager=no
make train licensemanager=no
make dist licensemanager=no


install $(ls -d $SRC_DIR/bin/* | grep -v bssm | grep -v gthdata) $PREFIX/bin/
install $SRC_DIR/bin/bssm/* $PREFIX/bin/bssm/
install $SRC_DIR/bin/gthdata/* $PREFIX/bin/gthdata/

else
install $(ls -d bin/* | grep -v bssm | grep -v gthdata) $PREFIX/bin/
install bin/bssm/* $PREFIX/bin/bssm/
install bin/gthdata/* $PREFIX/bin/gthdata/
fi
