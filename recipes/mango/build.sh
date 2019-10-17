#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $PACKAGE_HOME

ls $PACKAGE_HOME
cp -R core/* $PACKAGE_HOME

for f in $PACKAGE_HOME/bin/* ; do
    if [[ -f $f ]] ; then
        ln -s $f $BINARY_HOME/
    fi
done
#ln -s $PACKAGE_HOME/bin/mango-notebook $BINARY_HOME
#ln -s $PACKAGE_HOME/bin/mango-submit $BINARY_HOME
#ln -s $PACKAGE_HOME/bin/make_genome $BINARY_HOME

#echo "PYTHON VERSION----"
#$PYTHON --version
#echo $PY_VER
#which $PYTHON
#which python3.7

# modin
$PYTHON -m pip install python_modin/.[dask] --no-deps --ignore-installed -vv

# adam
$PYTHON -m pip install python_adam/. --no-deps --ignore-installed -vv

# mangos
$PYTHON -m pip install python/. --no-deps --ignore-installed -vv

$PYTHON -m pip install python_pileup/. --no-deps --ignore-installed -vv
# # Enable widget
# jupyter nbextension enable --py widgetsnbextension
# jupyter nbextension install --py --symlink --user bdgenomics.mango.pileup
# jupyter nbextension enable bdgenomics.mango.pileup --user --py

mkdir -p $PREFIX/mango-assembly/target
for f in $PACKAGE_HOME/*.jar ; do
    ln -s $f $PREFIX/mango-assembly/target/
done
