#!/bin/bash
# In addition to the installed lib dir we want to set the path to the share
# when libopenms is used
# TODO does this propagate to dependent packages?
mkdir -p $PREFIX/etc/conda/activate.d/ $PREFIX/etc/conda/deactivate.d/
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/libopenms.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/libopenms.sh

cmake -DCOMPONENT="library" -P build/cmake_install.cmake
cmake -DCOMPONENT="OpenMS_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="OpenSwathAlgo_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="thirdparty_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="share" -P build/cmake_install.cmake
cmake -DCOMPONENT="cmake" -P build/cmake_install.cmake
