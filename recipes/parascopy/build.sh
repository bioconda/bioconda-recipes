
cd freebayes
mkdir build
meson build/ --buildtype release
cd build
ninja -v
cp freebayes "${PREFIX}/_parascopy_freebayes"
cd ../../

$PYTHON -m pip install . --ignore-install --no-deps -vv

