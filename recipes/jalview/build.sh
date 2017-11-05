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
# Find original directory of bash script, resolving symlinks\
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128\
SOURCE="\${BASH_SOURCE[0]}"\
while [ -h "\$SOURCE" ]; do # resolve \$SOURCE until the file is no longer a symlink\
    DIR="\$( cd -P "\$( dirname "\$SOURCE" )" && pwd )"\
    SOURCE="\$(readlink "\$SOURCE")"\
    [[ \$SOURCE != /* ]] && SOURCE="\$DIR/\$SOURCE" # if \$SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located\
done\
DIR="\$( cd -P "\$( dirname "\$SOURCE" )" && pwd )"; # get final path of this script\
JALVIEWDIR=\$DIR`; # set install path of jalview\n\
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

