#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/etc/conda/activate.d/ $PREFIX/etc/conda/deactivate.d/
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/mango.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/mango.sh

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

ls $PACKAGE_HOME
cp -R core/* $PACKAGE_HOME

for f in $PACKAGE_HOME/bin/* ; do
    if [[ -f $f ]] ; then
        ln -s $f $BINARY_HOME/
    fi
done

# adam
$PYTHON -m pip install python_adam/. --no-deps --ignore-installed -vv

# mangos
$PYTHON -m pip install python/. --no-deps --ignore-installed -vv

$PYTHON -m pip install python_pileup/. --no-deps --ignore-installed -vv
# Enable widget
jupyter nbextension enable --py widgetsnbextension
jupyter nbextension install --overwrite --py --symlink --user bdgenomics.mango.pileup
jupyter nbextension enable bdgenomics.mango.pileup --user --py

mkdir -p $PREFIX/mango-assembly/target
for f in $PACKAGE_HOME/repo/*.jar ; do
    ln -s $f $PREFIX/mango-assembly/target/
done
