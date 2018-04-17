#!/bin/bash

$PYTHON "$RECIPE_DIR/fetch_inchi.py"
$PYTHON "$RECIPE_DIR/fetch_avalontools.py"
PY_INC=`$PYTHON -c "from distutils import sysconfig; print (sysconfig.get_python_inc(0, '$PREFIX'))"`

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    extra_flags="-DCMAKE_EXE_LINKER_FLAGS_RELEASE='-lrt'"
else
    extra_flags="-DBoost_USE_STATIC_LIBS=ON"
fi

export BOOST_LIBRARYDIR=$PREFIX/lib/

cmake \
    -DRDK_INSTALL_INTREE=OFF \
    -DRDK_INSTALL_STATIC_LIBS=OFF \
    -DRDK_BUILD_INCHI_SUPPORT=ON \
    -DRDK_BUILD_AVALON_SUPPORT=ON \
    -DRDK_USE_FLEXBISON=OFF \
    -DRDK_BUILD_THREADSAFE_SSS=ON \
    -DRDK_TEST_MULTITHREADED=ON \
    -DAVALONTOOLS_DIR=$SRC_DIR/External/AvalonTools/src/SourceDistribution \
    -DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DPython_ADDITIONAL_VERSIONS=${PY_VER} \
    -DPYTHON_EXECUTABLE=$PYTHON \
    -DPYTHON_INCLUDE_DIR=${PY_INC} \
    -DPYTHON_NUMPY_INCLUDE_PATH=$SP_DIR/numpy/core/include \
    -DBOOST_ROOT=$PREFIX -D Boost_NO_SYSTEM_PATHS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    $extra_flags \
    .

make -j4 install
