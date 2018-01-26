#!/bin/bash

PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $PACKAGE_HOME
mkdir -p $PREFIX/bin

cp -r * $PACKAGE_HOME


#WRAPPER=$PREFIX/bin/Jelly.py
#echo "#!/bin/sh" > $WRAPPER
#echo "PYTHONPATH=$PACKAGE_HOME:\$PYTHONPATH $PACKAGE_HOME/bin/Jelly.py \$@" >> $WRAPPER
#chmod +x $WRAPPER


for f in bin/*.py
do
  echo "Processing $f file..."
  fn=basename $f

  WRAPPER=$PREFIX/bin/$fn
  echo "#!/bin/sh" > $WRAPPER
  echo "PYTHONPATH=$PACKAGE_HOME:\$PYTHONPATH $PACKAGE_HOME/bin/$fn \$@" >> $WRAPPER
  chmod +x $WRAPPER
done
