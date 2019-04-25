#!/usr/bin/env bash




# install 
DESTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $DESTDIR
cp run_qc.py $DESTDIR
cp -r magpurify $DESTDIR
chmod +x $DESTDIR/run_qc.py

ln -s $DESTDIR/run_qc.py $PREFIX/bin/
ln -s $DESTDIR/run_qc.py $PREFIX/bin/MAGpurify #alias

# unzip database
tar -jxvf MAGpurify-db-v1.0.tar.bz2
mv MAGpurify-db-v1.0 $DESTDIR
export MAGPURIFYDB=$DESTDIR/MAGpurify-db-v1.0
