#!/bin/bash

install -d $PREFIX/include
install -d $PREFIX/include/seqan3/submodules/cereal/include/
install -d $PREFIX/include/seqan3/submodules/range-v3/include/
install -d $PREFIX/include/seqan3/submodules/sdsl/include/
install -d $PREFIX/share/cmake
cp -r $SRC_DIR/include/seqan3 $PREFIX/include
cp -r $SRC_DIR/build_system/seqan3-config.cmake $PREFIX/share/cmake
cp -r $SRC_DIR/submodules/cereal/include/cereal $PREFIX/include/seqan3/submodules/cereal/include/
cp -r $SRC_DIR/submodules/range-v3/include/range $PREFIX/include/seqan3/submodules/range-v3/include/
cp -r $SRC_DIR/submodules/range-v3/include/meta $PREFIX/include/seqan3/submodules/range-v3/include/
cp -r $SRC_DIR/submodules/range-v3/include/concepts $PREFIX/include/seqan3/submodules/range-v3/include/
cp -r $SRC_DIR/submodules/range-v3/include/std $PREFIX/include/seqan3/submodules/range-v3/include/
cp -r $SRC_DIR/submodules/sdsl-lite/include/sdsl $PREFIX/include/seqan3/submodules/sdsl/include/
