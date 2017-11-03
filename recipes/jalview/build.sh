
# compile jalview from source
cd jalview
ant makedist

# create target directory
JALVIEWDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir $JALVIEWDIR

# copy files to target
cp -R dist/* $JALVIEWDIR/.

# create wrapper script
echo -e '#!/usr/bin/env bash\n\
JALVIEWDIR=$JALVIEWDIR;\n\
java -Djava.awt.headless=true -Djava.ext.dirs=\$JALVIEWDIR -cp \$JALVIEWDIR/jalview.jar jalview.bin.Jalview \${@};\n\
' | tr -d '\\' > $JALVIEWDIR/jalview.sh; 
chmod u+x $JALVIEWDIR/jalview.sh; 

# link wrapper script
ln -s $JALVIEWDIR/jalview.sh $PREFIX/bin/jalview

