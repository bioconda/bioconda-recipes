#!/bin/bash

# compile jalview from source
#cd jalview
ant makedist

# create target directory
JALVIEWDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $JALVIEWDIR

# copy files to target
cp -R dist/* $JALVIEWDIR/.

# create wrapper script
echo -e '#!/usr/bin/env bash\n\
JALVIEWDIR=$JALVIEWDIR;\n\
java -Djava.awt.headless=true -Djava.ext.dirs=\$JALVIEWDIR -cp \$JALVIEWDIR/jalview.jar jalview.bin.Jalview \${@};\n\
' | tr -d '\\' > $JALVIEWDIR/jalview.sh; 
chmod 0755 $JALVIEWDIR/jalview.sh; 

# link wrapper script
mkdir -p $PREFIX/bin
ln -s $JALVIEWDIR/jalview.sh $PREFIX/bin/jalview
chmod 0755 $PREFIX/bin/jalview; 

