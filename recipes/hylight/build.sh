#!/usr/bin/env bashscript

if [ "$(uname)" == "Darwin" ]; then
    cd ${SRC_DIR}
    cp ${SRC_DIR}/HyLight ${PREFIX}
else
    cd ${SRC_DIR}
    ${PYTHON} -m pip install . -vvv
    hylight_conda_dir=${PREFIX}/lib/python3.6/site-packages/HyLight
    chmod +x $hylight_conda_dir/script/*py
    cd ${SRC_DIR}/HyLight/tools/miniasm
    make clean
    make CC="${CC}" CPPFLAGS="${CPPFLAGS}" LIBS="${LDFLAGS} -lm -lz -lpthread"
    cp ${SRC_DIR}/HyLight/tools/miniasm/miniasm $hylight_conda_dir/tools/miniasm
    cd ${SRC_DIR}/HyLight/tools/HaploConduct
    make clean
    make CC=$CXX CPPFLAGS="-Wall -fopenmp -std=c++11 -g -O2 -L$PREFIX/lib"
    cp bin quick-cliques/bin $hylight_conda_dir/tools/HaploConduct -r
fi
