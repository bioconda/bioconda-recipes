#!/bin/bash

PREFIX=$CONDA_PREFIX
DESTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

mkdir -p $PREFIX/bin/
mkdir -p $DESTDIR

cp -r ./dist/* $DESTDIR
cp -r ./databases/ $DESTDIR

# companion script to run MetaWatt
echo '#!/usr/bin/env bash' > $DESTDIR/metawatt
echo "WD=\"$DESTDIR\"" >> $DESTDIR/metawatt
echo 'JAR="$WD/MetaWatt-*.jar"' >> $DESTDIR/metawatt
echo 'MEM="2g"' >> $DESTDIR/metawatt
echo 'pushd $WD > /dev/null' >> $DESTDIR/metawatt
echo 'java -Xmx$MEM -jar $JAR "$@"' >> $DESTDIR/metawatt
echo 'popd > /dev/null' >> $DESTDIR/metawatt

chmod u+x $DESTDIR/metawatt
ln -s $DESTDIR/metawatt $PREFIX/bin/
