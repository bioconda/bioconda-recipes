#!/bin/bash

mkdir -p $PREFIX/bin

cp $SRC_DIR/install_slam.sh $PREFIX/bin/install_slam.sh && chmod +x $PREFIX/bin/install_slam.sh

pushd build > /dev/null
make
popd > /dev/null

cp $SRC_DIR/build/SLAM $PREFIX/bin/SLAM && chmod +x $PREFIX/bin/SLAM