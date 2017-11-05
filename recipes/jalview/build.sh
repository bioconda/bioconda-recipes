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
JALVIEWDIR=`dirname "\$(readlink -f "´\$0")"`; # get path of this script file\n\
JALVIEWDIR=`readlink -f \$JALVIEWDIR; # back to full abs path\n\
echo "JALVIEWDIR=\$JALVIEWDIR"; # debug\n\
ls \$JALVIEWDIR; # debug\n\
which jalview; # debug\n\
echo `pwd`; # debug\n\
echo "java -Djava.awt.headless=true -Djava.ext.dirs=\$JALVIEWDIR -cp \$JALVIEWDIR/jalview.jar jalview.bin.Jalview \${@};"; # debug\n\
java -Djava.awt.headless=true -Djava.ext.dirs=\$JALVIEWDIR -cp \$JALVIEWDIR/jalview.jar jalview.bin.Jalview \${@}; # forward call\n\
' | tr -d '\\' > $JALVIEWDIR/jalview.sh; 
chmod +x $JALVIEWDIR/jalview.sh; 

# link wrapper script
mkdir -p $PREFIX/bin
ln -s $JALVIEWDIR/jalview.sh $PREFIX/bin/jalview
chmod +x $PREFIX/bin/jalview; 

