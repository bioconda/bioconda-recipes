#!/usr/bin/env bash
set -vex

cd pypeflow
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_kit
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_unzip
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..
cd falcon_phase
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
cd ..

cd pb-falcon-phase

cd src
echo ${CC}
which ${CC}
meson --prefix "${PREFIX}" --buildtype=release ./build-meson
ninja -C ./build-meson -v install
#cp -f ./build-meson/falcon-phase ${PREFIX}/bin # we want RPATH munging from Meson
cd ..

cd bin
ls -larth
cp fc_primary_contig_index.pl fc_scrub_names.pl FALCON_headerConverter.pl $PREFIX/bin
cd ..

cd ..
