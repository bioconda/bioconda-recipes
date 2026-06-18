#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]; then
	${PYTHON} -m pip install . --no-build-isolation --no-cache-dir --no-deps -vvv
else
	${PYTHON} -m pip install . --no-build-isolation --no-cache-dir --no-deps -vvv
	hylight_conda_dir="${PREFIX}/lib/python3.6/site-packages/HyLight"
	chmod +x $hylight_conda_dir/script/*py
	cd ${SRC_DIR}/HyLight/tools/miniasm
	make clean
	make CC="${CC}" CPPFLAGS="${CPPFLAGS}" LIBS="${LDFLAGS} -lm -lz -lpthread -L${PREFIX}/lib" -j"${CPU_COUNT}"
	cp -rf ${SRC_DIR}/HyLight/tools/miniasm/miniasm $hylight_conda_dir/tools/miniasm
	cd ${SRC_DIR}/HyLight/tools/HaploConduct
	make clean
	make CC="${CXX}" CPPFLAGS="-Wall -fopenmp -std=c++14 -g -O3 -L${PREFIX}/lib -I${PREFIX}/include" -j"${CPU_COUNT}"
	cp -rf bin quick-cliques/bin $hylight_conda_dir/tools/HaploConduct -r
fi
