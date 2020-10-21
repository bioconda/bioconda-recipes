cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON .

make VERBOSE=1
make install

cd scripts/energy-estimation-utility
"${PYTHON}" -m pip install . --no-deps -vv
