
rm -df freebayes
git clone --recursive https://github.com/tprodanov/freebayes.git

cd freebayes
mkdir build
meson build/ --buildtype release
cd build
ninja -v
cp freebayes "${PREFIX}/bin/_parascopy_freebayes"
cd ../../

$PYTHON -m pip install . --ignore-install --no-deps -vv

