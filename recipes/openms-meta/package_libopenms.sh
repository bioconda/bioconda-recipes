#!/bin/bash
# In addition to the installed lib dir we want to set the path to the share
# when libopenms is used
# TODO does this propagate to dependent packages?
mkdir -p $PREFIX/etc/conda/activate.d/ $PREFIX/etc/conda/deactivate.d/
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/libopenms.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/libopenms.sh

mkdir -p $PREFIX/lib
cp -R build/lib/* $PREFIX/lib/
# Copy share, excluding examples
mkdir -p $PREFIX/share/OpenMS/examples
shopt -s extglob
cp -R share/!(OpenMS) $PREFIX/share/
cp -R share/OpenMS/!(examples) $PREFIX/share/OpenMS
# Copy the default models from the examples/simulation folder.
# TODO move models and remove this exception in later OpenMS releases
cp -R share/OpenMS/examples/simulation $PREFIX/share/OpenMS/examples/
mkdir -p $PREFIX/include
cp -R build/src/openms/include/* $PREFIX/include/
cp -R build/src/openswathalgo/include/* $PREFIX/include/
cp -R build/src/superhirn/include/* $PREFIX/include/
