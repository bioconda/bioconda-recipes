#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
mkdir -p wildmagic/include
find wildmagic -name *.h -exec cp {} wildmagic/include/ \;
find wildmagic -name *.inl -exec cp {} wildmagic/include/ \;

pushd src/pyOpenMS
echo "OPEN_MS_COMPILER=\"$CXX\"" >> env.py
echo "OPEN_MS_SRC=\"$SRC_DIR\"" >> env.py
echo "OPEN_MS_BUILD_DIR=\"$SRC_DIR/build\"" >> env.py
echo "PYOPENMS_INCLUDE_DIRS=\"$SRC_DIR/wildmagic/include;$PREFIX/include;$SRC_DIR/src/openswathalgo/include;$SRC_DIR/build/src/openswathalgo/include;$SRC_DIR/src/openswathalgo/thirdparty/MIToolbox/include;$SRC_DIR/src/openswathalgo/thirdparty/MIToolbox/src;$PREFIX/include;$SRC_DIR/src/openms/include;$SRC_DIR/build/src/openms/include;../../contrib-build/include;$PREFIX/include/eigen3;$SRC_DIR/contrib-build/include/WildMagic;$PREFIX/include/qt/;$PREFIX/include/qt/QtCore;$PREFIX/.//mkspecs/linux-g++;$PREFIX/include/qt/QtNetwork;$SRC_DIR/src/superhirn/include;$SRC_DIR/build/src/superhirn/include;$PREFIX/include/qt;$SRC_DIR/wildmagic/LibMathematics/Algebra;$SRC_DIR/wildmagic/LibMathematics;$SRC_DIR/wildmagic/LibMathematics/Algebra;$SRC_DIR/wildmagic/LibCore;$SRC_DIR/wildmagic/LibCore/DataTypes;$SRC_SIR/wildmagic/LibMathematics/Base\"" >> env.py
echo "QT_QMAKE_VERSION_INFO=\"QMake version 3.1\"" >> env.py
echo "OPEN_MS_CONTRIB_BUILD_DIRS=\"../../contrib-build\"" >> env.py
echo "INCLUDE_DIRS_EXTEND=[\"$PREFIX/include\"]" >> env.py
echo "LIBRARIES_EXTEND=[\"$PREFIX/lib\"]" >> env.py
echo "LIBRARY_DIRS_EXTEND=[]" >> env.py
echo "QT_INSTALL_LIBS=\"$PREFIX/lib\"" >> env.py
echo "QT_INSTALL_BINS=\"$PREFIX/bin\"" >> env.py
echo "MSVS_RTLIBS=\"\"" >> env.py
echo "Boost_MAJOR_VERSION=\"1\"" >> env.py
echo "Boost_MINOR_VERSION=\"68\"" >> env.py
echo "OPEN_MS_BUILD_TYPE=\"Release\"" >> env.py
echo "OPEN_MS_VERSION=\"2.4.0\"" >> env.py
echo "OPEN_SWATH_ALGO_LIB=\"\"" >> env.py
echo "OPEN_MS_LIB=\"\"" >> env.py
echo "SUPERHIRN_LIB=\"\"" >> env.py
echo "PY_NUM_THREADS=\"1\"" >> env.py
echo "PY_NUM_MODULES=\"8\"" >> env.py
$PYTHON create_cpp_extension.py
$PYTHON -m pip install . --ignore-installed --no-deps -vv
exit 0

# Use C++17 rather than C++11 to hopefully better match boost
sed -i.bak "s/11/17/g" CMakeLists.txt

mkdir contrib-build
cd contrib-build
cmake -DBUILD_TYPE=WILDMAGIC ../contrib


mkdir -p $PREFIX/etc/conda/activate.d/ $PREFIX/etc/conda/deactivate.d/
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/pyopenms.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/pyopenms.sh

cd ..
mkdir build
cd build

ORIGIN='$ORIGIN'
export ORIGIN
LDFLAGS='-Wl,-rpath,$${ORIGIN}/../lib'

cmake .. -DPYOPENMS=ON -DWITH_GUI=OFF -DOPENMS_CONTRIB_LIBS='../../contrib-build' -DCMAKE_INSTALL_PREFIX=$PREFIX -DHAS_XSERVER=OFF -DENABLE_TUTORIALS=OFF -DENABLE_STYLE_TESTING=OFF -DENABLE_UNITYBUILD=OFF -DWITH_GUI=OFF -DBoost_LIB_VERSION=1.70.0 -DBoost_INCLUDE_DIR=$PREFIX/include -DBoost_LIBRARY_DIRS=$PREFIX/lib -DBoost_LIBRARIES=$PREFIX/lib -DBoost_DEBUG=ON -DBOOST_LIBRARYDIR=$PREFIX/lib/ -DBOOST_USE_STATIC=OFF

make -j2 VERBOSE=1 pyopenms || cat ../src/pyOpenMS/env.py
find $SRC_DIR -name env.p* -print
find $SRC_DIR -name env.p* -exec cat {} \;
exit 1
make install
